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

    // MARK: Results
    var currentSession: RecordingSession?
    var mergedOutput: String = ""
    var showResult = false

    // MARK: Services
    let audioRecorder = AudioRecorderService()
    let clipboardMonitor = ClipboardMonitorService()
    let transcriptionService = TranscriptionService()
    let mergerService = MergerService()

    // MARK: Timer
    private var durationTimer: Timer?

    init() {
        // Register global keyboard shortcut
        KeyboardShortcuts.onKeyUp(for: .toggleRecording) { [weak self] in
            Task { @MainActor in
                self?.toggleRecording()
            }
        }

        // Pre-load the Whisper model in the background so first recording is fast
        Task {
            await transcriptionService.preload()
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

        // Reset state
        mergedOutput = ""
        showResult = false
        currentSession = nil
        recordingDuration = 0

        // Start services
        clipboardMonitor.startMonitoring()

        do {
            try audioRecorder.startRecording()
            isRecording = true

            // Start duration timer
            durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.recordingDuration += 0.1
                }
            }
        } catch {
            print("❌ Failed to start recording: \(error)")
        }
    }

    func stopRecording() {
        guard isRecording else { return }

        isRecording = false
        durationTimer?.invalidate()
        durationTimer = nil

        // Stop services and capture results
        let audioFileURL = audioRecorder.stopRecording()
        let clipboardItems = clipboardMonitor.stopMonitoring()
        let recordingStartTime = audioRecorder.recordingStartTime

        guard let audioURL = audioFileURL else {
            processingStatus = "Ses kaydı alınamadı."
            return
        }

        // Start async processing
        isProcessing = true
        processingStatus = "Ses metne çevriliyor..."

        Task {
            do {
                // 1. Transcribe audio
                let segments = try await transcriptionService.transcribe(audioFileURL: audioURL)

                // 2. Merge with clipboard items
                processingStatus = "Pano içerikleri eşleştiriliyor..."
                let merged = mergerService.merge(
                    transcriptSegments: segments,
                    clipboardItems: clipboardItems,
                    recordingStartTime: recordingStartTime
                )

                // 3. Build session and output
                let session = RecordingSession(
                    id: UUID(),
                    date: Date(),
                    duration: recordingDuration,
                    audioFileURL: audioURL,
                    transcriptSegments: segments,
                    clipboardItems: clipboardItems,
                    mergedOutput: merged
                )

                await MainActor.run {
                    self.currentSession = session
                    self.mergedOutput = merged
                    self.copyOutputToClipboard() // Otomatik kopyalama eklendi
                    self.isProcessing = false
                    self.processingStatus = ""
                    self.showResult = true
                }
            } catch {
                await MainActor.run {
                    self.isProcessing = false
                    self.processingStatus = "Hata: \(error.localizedDescription)"
                }
            }
        }
    }

    func copyOutputToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(mergedOutput, forType: .string)
    }

    /// Formatted duration string (mm:ss)
    var formattedDuration: String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
