import Foundation
import WhisperKit

/// Transcribes audio files using WhisperKit (offline, on-device).
final class TranscriptionService: @unchecked Sendable {

    private var whisperKit: WhisperKit?
    private var isLoading = false

    private static let modelStorageDir: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("Dikte/Models", isDirectory: true)
    }()

    func preload() async {
        guard whisperKit == nil, !isLoading else { return }
        isLoading = true

        let modelDir = Self.modelStorageDir
        let modelName = "openai_whisper-large-v3_turbo"

        try? FileManager.default.createDirectory(at: modelDir, withIntermediateDirectories: true)

        let expectedModelPath = modelDir.appendingPathComponent(modelName)
        let modelExists = FileManager.default.fileExists(atPath: expectedModelPath.path)

        print("[Dikte] Model \(modelExists ? "cache'den yükleniyor" : "indiriliyor (~954 MB)")...")

        let t = Date()
        do {
            let config = WhisperKitConfig(
                model: modelName,
                downloadBase: modelDir,
                modelFolder: modelExists ? expectedModelPath.path : nil,
                verbose: false,
                logLevel: .none,
                prewarm: true,
                load: true,
                download: true
            )
            whisperKit = try await WhisperKit(config)
            print("[Dikte] Model hazır (\(String(format: "%.1f", Date().timeIntervalSince(t)))s)")
        } catch {
            print("[Dikte] Model yüklenemedi: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func transcribe(audioFileURL: URL) async throws -> [TranscriptSegment] {
        if whisperKit == nil { await preload() }

        guard let whisper = whisperKit else {
            throw TranscriptionError.modelNotLoaded
        }

        let t = Date()
        let results = try await whisper.transcribe(
            audioPath: audioFileURL.path,
            decodeOptions: DecodingOptions(
                language: "tr",
                wordTimestamps: true,
                suppressBlank: false
            )
        )

        var segments: [TranscriptSegment] = []
        for result in results {
            for segment in result.segments {
                let cleaned = Self.cleanTranscriptText(segment.text)
                guard !cleaned.isEmpty else { continue }
                segments.append(TranscriptSegment(
                    id: UUID(),
                    text: cleaned,
                    startTime: TimeInterval(segment.start),
                    endTime: TimeInterval(segment.end)
                ))
            }
        }

        print("[Dikte] Transkripsiyon tamamlandı: \(segments.count) segment, \(String(format: "%.1f", Date().timeIntervalSince(t)))s")
        return segments
    }

    // MARK: - Text Cleaning

    private static func cleanTranscriptText(_ text: String) -> String {
        var cleaned = text

        if let regex = try? NSRegularExpression(pattern: #"<\|[^|]*\|>"#) {
            cleaned = regex.stringByReplacingMatches(
                in: cleaned,
                range: NSRange(cleaned.startIndex..., in: cleaned),
                withTemplate: ""
            )
        }

        let hallucinations = [
            "Altyazı M.K.", "Altyazılar M.K.", "Alt yazı M.K.",
            "Altyazı:", "Çeviri:", "Altyazı çeviri",
            "www.", ".com", "Abone ol", "Beğen",
        ]
        for h in hallucinations {
            cleaned = cleaned.replacingOccurrences(of: h, with: "")
        }

        if let regex = try? NSRegularExpression(pattern: #"\s+"#) {
            cleaned = regex.stringByReplacingMatches(
                in: cleaned,
                range: NSRange(cleaned.startIndex..., in: cleaned),
                withTemplate: " "
            )
        }

        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum TranscriptionError: LocalizedError {
    case modelNotLoaded
    var errorDescription: String? { "Whisper modeli yüklenemedi." }
}
