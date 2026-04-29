import Foundation
import SwiftUI
import KeyboardShortcuts

// MARK: - Global Keyboard Shortcut Names

extension KeyboardShortcuts.Name {
    /// Toggle recording on / off (default: ⌘⇧Space)
    static let toggleRecording = Self(
        "toggleRecording",
        default: .init(.space, modifiers: [.command, .shift])
    )
}

// MARK: - App State

/// Central observable state that drives the entire app.
@MainActor
@Observable
final class AppState {

    // MARK: Recording state
    var isRecording = false
    var recordingDuration: TimeInterval = 0

    // MARK: Processing state
    var isProcessing = false
    var processingStatus: String = ""
    var processingError: String?

    // MARK: Results
    var currentSession: RecordingSession?
    var mergedOutput: String = ""
    var showResult = false

    // MARK: Model readiness
    enum ModelReadyState: Equatable {
        case preparing
        case ready
        case failed(String)
    }
    var modelReadyState: ModelReadyState = .preparing

    // MARK: Services
    let audioRecorder = AudioRecorderService()
    let clipboardMonitor = ClipboardMonitorService()
    let transcriptionService = TranscriptionService()
    let mergerService = MergerService()
    let audioInputRouteService = AudioInputRouteService()
    let outputSilenceService = OutputSilenceService()

    // MARK: Timer
    private var durationTimer: Timer?
    private var activeRecordingID: String?

    init() {
        // Register global keyboard shortcut
        KeyboardShortcuts.onKeyUp(for: .toggleRecording) { [weak self] in
            Task { @MainActor in
                self?.toggleRecording()
            }
        }

        // Pre-load the Whisper model in the background so first recording is fast.
        // XCTest launches the app target as a test host; avoid model downloads there.
        if !Self.isRunningTests {
            FloatingHUDManager.shared.showHUD(appState: self)
            Task {
                do {
                    try await transcriptionService.preload()
                    await MainActor.run {
                        self.modelReadyState = .ready
                    }
                } catch {
                    await MainActor.run {
                        self.modelReadyState = .failed(error.localizedDescription)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    func startRecording() {
        guard !isRecording else { return }

        let sessionID = Self.makeLogSessionID()
        activeRecordingID = sessionID
        DikteLog.action("app", "recording.start.request", "Kayıt başlatma isteği alındı.", metadata: [
            "session": sessionID
        ])

        // Reset state
        mergedOutput = ""
        showResult = false
        processingError = nil
        currentSession = nil
        recordingDuration = 0

        do {
            if !Self.isRunningTests {
                try audioInputRouteService.routeToBuiltInForRecording(sessionID: sessionID)
            }
            try audioRecorder.startRecording(sessionID: sessionID)
            if !Self.isRunningTests {
                outputSilenceService.silenceForRecording(sessionID: sessionID)
            }
            clipboardMonitor.startMonitoring(sessionID: sessionID)
            isRecording = true
            DikteLog.action("app", "recording.started", "Kayıt akışı aktif.", metadata: [
                "session": sessionID
            ])

            // Start duration timer
            durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.recordingDuration += 0.1
                }
            }
        } catch {
            if !Self.isRunningTests {
                outputSilenceService.restore(sessionID: sessionID)
                audioInputRouteService.restoreDefaultInput(sessionID: sessionID)
            }
            activeRecordingID = nil
            DikteLog.error("app", "recording.start.failed", error.localizedDescription, metadata: [
                "session": sessionID
            ])
            processingStatus = error.localizedDescription
        }
    }

    func stopRecording() {
        guard isRecording else { return }

        isRecording = false
        durationTimer?.invalidate()
        durationTimer = nil
        let sessionID = activeRecordingID ?? Self.makeLogSessionID()
        let sessionDuration = recordingDuration
        DikteLog.action("app", "recording.stop.request", "Kayıt durdurma isteği alındı.", metadata: [
            "session": sessionID,
            "ui_duration_s": Self.formatSeconds(sessionDuration)
        ])

        // Stop services and capture results
        let audioFileURL = audioRecorder.stopRecording(sessionID: sessionID)
        if !Self.isRunningTests {
            outputSilenceService.restore(sessionID: sessionID)
            audioInputRouteService.restoreDefaultInput(sessionID: sessionID)
        }
        let clipboardItems = clipboardMonitor.stopMonitoring(sessionID: sessionID)
        let recordingStartTime = audioRecorder.recordingStartTime

        guard let audioURL = audioFileURL else {
            processingStatus = audioRecorder.lastErrorMessage ?? "Ses kaydı alınamadı."
            activeRecordingID = nil
            DikteLog.error("app", "processing.skipped", "Ses dosyası üretilemediği için işlem atlandı.", metadata: [
                "clipboard_items": clipboardItems.count,
                "session": sessionID
            ])
            return
        }

        // Start async processing
        isProcessing = true
        processingStatus = "Ses metne çevriliyor..."
        let processingStartTime = Date()
        DikteLog.action("app", "processing.start", "Kayıt sonrası işlem başladı.", metadata: [
            "audio_file": audioURL.lastPathComponent,
            "clipboard_items": clipboardItems.count,
            "session": sessionID,
            "ui_duration_s": Self.formatSeconds(sessionDuration)
        ])

        Task {
            do {
                // 1. Transcribe audio
                let requiresWordTimestamps = !clipboardItems.isEmpty
                let segments = try await transcriptionService.transcribe(
                    audioFileURL: audioURL,
                    requiresWordTimestamps: requiresWordTimestamps,
                    sessionID: sessionID
                )

                // 2. Merge with clipboard items
                processingStatus = "Pano içerikleri eşleştiriliyor..."
                let merged = mergerService.merge(
                    transcriptSegments: segments,
                    clipboardItems: clipboardItems,
                    recordingStartTime: recordingStartTime
                )
                DikteLog.info("app", "merge.complete", "Transkript ve pano öğeleri birleştirildi.", metadata: [
                    "clipboard_items": clipboardItems.count,
                    "output_chars": merged.count,
                    "segments": segments.count,
                    "word_timestamps": requiresWordTimestamps,
                    "session": sessionID
                ])

                // 3. Build session and output
                let session = RecordingSession(
                    id: UUID(),
                    date: Date(),
                    duration: sessionDuration,
                    audioFileURL: audioURL,
                    transcriptSegments: segments,
                    clipboardItems: clipboardItems,
                    mergedOutput: merged
                )

                await MainActor.run {
                    self.currentSession = session
                    self.mergedOutput = merged
                    self.copyOutputToClipboard(sessionID: sessionID)
                    self.isProcessing = false
                    self.processingStatus = ""
                    self.showResult = true
                    self.activeRecordingID = nil
                    DikteLog.action("app", "processing.complete", "Sonuç hazır.", metadata: [
                        "elapsed_s": Self.formatSeconds(Date().timeIntervalSince(processingStartTime)),
                        "session": sessionID
                    ])
                }
            } catch {
                await MainActor.run {
                    self.isProcessing = false
                    self.processingStatus = "Hata: \(error.localizedDescription)"
                    self.processingError = error.localizedDescription
                    self.activeRecordingID = nil
                    DikteLog.error("app", "processing.failed", error.localizedDescription, metadata: [
                        "elapsed_s": Self.formatSeconds(Date().timeIntervalSince(processingStartTime)),
                        "session": sessionID
                    ])
                }
            }
        }
    }

    func releaseAudioRouting() {
        outputSilenceService.restore(sessionID: activeRecordingID)
        audioInputRouteService.restoreDefaultInput(sessionID: activeRecordingID)
    }

    func copyOutputToClipboard(sessionID: String? = nil) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(mergedOutput, forType: .string)
        DikteLog.action("clipboard", "output.copy", "Birleştirilmiş çıktı panoya yazıldı.", metadata: [
            "chars": mergedOutput.count,
            "session": sessionID ?? "-"
        ])
    }

    /// Formatted duration string (mm:ss)
    var formattedDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private static var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    private static func makeLogSessionID() -> String {
        String(UUID().uuidString.prefix(8)).lowercased()
    }

    private static func formatSeconds(_ value: TimeInterval) -> String {
        String(format: "%.2f", value)
    }
}
