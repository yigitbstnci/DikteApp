import Foundation
import AVFoundation
import WhisperKit

/// Transcribes audio files using WhisperKit (offline, on-device).
actor TranscriptionService {

    private var whisperKit: WhisperKit?
    private var loadingTask: Task<WhisperKit, Error>?

    private static let modelName = "openai_whisper-large-v3_turbo"

    private static let modelStorageDir: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("Dikte/Models", isDirectory: true)
    }()

    func preload() async {
        do {
            _ = try await loadWhisperKit()
        } catch {
            DikteLog.error("stt", "model.preload", "Model yüklenemedi: \(error.localizedDescription)", metadata: [
                "model": Self.modelName
            ])
        }
    }

    func transcribe(audioFileURL: URL, sessionID: String? = nil) async throws -> [TranscriptSegment] {
        let whisper = try await loadWhisperKit(sessionID: sessionID)
        let audioDuration = Self.audioDuration(of: audioFileURL)
        let byteCount = Self.fileSize(of: audioFileURL)

        let t = Date()
        DikteLog.action("stt", "transcribe.start", "Whisper transkripsiyonu başladı.", metadata: DikteLog.metadata([
            "audio_duration_s": String(format: "%.2f", audioDuration),
            "bytes": byteCount,
            "file": audioFileURL.lastPathComponent,
            "language": "tr",
            "word_timestamps": true
        ], sessionID: sessionID))

        let results = try await whisper.transcribe(
            audioPath: audioFileURL.path,
            decodeOptions: Self.primaryDecodingOptions
        )

        Self.logResults(results, event: "transcribe.primary", sessionID: sessionID)
        var segments = Self.makeTranscriptSegments(from: results, audioDuration: audioDuration)

        if segments.isEmpty {
            DikteLog.warning("stt", "transcribe.retry", "Segment bulunamadı; düz transkripsiyon modunda tekrar deneniyor.", metadata: DikteLog.metadata([
                "word_timestamps": false
            ], sessionID: sessionID))
            let fallbackResults = try await whisper.transcribe(
                audioPath: audioFileURL.path,
                decodeOptions: Self.fallbackDecodingOptions
            )
            Self.logResults(fallbackResults, event: "transcribe.fallback", sessionID: sessionID)
            segments = Self.makeTranscriptSegments(from: fallbackResults, audioDuration: audioDuration)
        }

        DikteLog.action("stt", "transcribe.complete", "Transkripsiyon tamamlandı.", metadata: DikteLog.metadata([
            "elapsed_s": String(format: "%.2f", Date().timeIntervalSince(t)),
            "segments": segments.count
        ], sessionID: sessionID))
        return segments
    }

    private static var primaryDecodingOptions: DecodingOptions {
        DecodingOptions(
            language: "tr",
            wordTimestamps: true,
            suppressBlank: false
        )
    }

    private static var fallbackDecodingOptions: DecodingOptions {
        DecodingOptions(
            language: "tr",
            wordTimestamps: false,
            suppressBlank: false,
            firstTokenLogProbThreshold: nil,
            noSpeechThreshold: nil
        )
    }

    private static func makeTranscriptSegments(
        from results: [TranscriptionResult],
        audioDuration: TimeInterval
    ) -> [TranscriptSegment] {
        var transcriptSegments: [TranscriptSegment] = []

        for result in results {
            for segment in result.segments {
                let cleaned = cleanTranscriptText(segment.text)
                guard !cleaned.isEmpty else { continue }

                let words = (segment.words ?? []).compactMap { word -> TranscriptWord? in
                    let cleanedWord = cleanTranscriptText(word.word)
                    guard !cleanedWord.isEmpty else { return nil }
                    return TranscriptWord(
                        text: cleanedWord,
                        startTime: TimeInterval(word.start),
                        endTime: TimeInterval(max(word.end, word.start))
                    )
                }

                transcriptSegments.append(TranscriptSegment(
                    text: cleaned,
                    startTime: TimeInterval(segment.start),
                    endTime: TimeInterval(max(segment.end, segment.start)),
                    words: words
                ))
            }
        }

        if transcriptSegments.isEmpty {
            for result in results {
                let cleaned = cleanTranscriptText(result.text)
                guard !cleaned.isEmpty else { continue }
                transcriptSegments.append(TranscriptSegment(
                    text: cleaned,
                    startTime: 0,
                    endTime: max(audioDuration, 0.1)
                ))
            }
        }

        return transcriptSegments
    }

    private static func audioDuration(of url: URL) -> TimeInterval {
        guard let file = try? AVAudioFile(forReading: url) else { return 0 }
        let sampleRate = file.fileFormat.sampleRate
        guard sampleRate > 0 else { return 0 }
        return Double(file.length) / sampleRate
    }

    private static func fileSize(of url: URL) -> Int64 {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return (attributes?[.size] as? Int64) ?? 0
    }

    private static func logResults(_ results: [TranscriptionResult], event: String, sessionID: String?) {
        let rawSegmentCount = results.reduce(0) { $0 + $1.segments.count }
        let textCharacterCount = results.reduce(0) { $0 + cleanTranscriptText($1.text).count }
        DikteLog.info("stt", event, "Whisper sonucu alındı.", metadata: DikteLog.metadata([
            "raw_segments": rawSegmentCount,
            "results": results.count,
            "text_chars": textCharacterCount
        ], sessionID: sessionID))
    }

    // MARK: - Model Loading

    private func loadWhisperKit(sessionID: String? = nil) async throws -> WhisperKit {
        if let whisperKit {
            return whisperKit
        }

        if let loadingTask {
            return try await loadingTask.value
        }

        let task = Task {
            try await Self.makeWhisperKit(sessionID: sessionID)
        }
        loadingTask = task

        do {
            let loaded = try await task.value
            whisperKit = loaded
            loadingTask = nil
            return loaded
        } catch {
            loadingTask = nil
            throw error
        }
    }

    private static func makeWhisperKit(sessionID: String? = nil) async throws -> WhisperKit {
        let modelDir = modelStorageDir
        try FileManager.default.createDirectory(at: modelDir, withIntermediateDirectories: true)

        let cachedFolder = cachedModelFolder(in: modelDir)
        DikteLog.action("stt", "model.load", cachedFolder == nil ? "Model indiriliyor (~954 MB)." : "Model cache'den yükleniyor.", metadata: DikteLog.metadata([
            "cache_hit": cachedFolder != nil,
            "model": modelName,
            "model_dir": modelDir.path
        ], sessionID: sessionID))

        let t = Date()
        let config = WhisperKitConfig(
            model: modelName,
            downloadBase: modelDir,
            modelFolder: cachedFolder?.path,
            verbose: false,
            logLevel: .none,
            prewarm: true,
            load: true,
            download: true
        )
        let kit = try await WhisperKit(config)
        DikteLog.action("stt", "model.ready", "Whisper modeli hazır.", metadata: DikteLog.metadata([
            "elapsed_s": String(format: "%.2f", Date().timeIntervalSince(t)),
            "model": modelName
        ], sessionID: sessionID))
        return kit
    }

    static func cachedModelFolder(in modelDir: URL) -> URL? {
        let candidates = [
            modelDir.appendingPathComponent("models/argmaxinc/whisperkit-coreml/\(modelName)", isDirectory: true),
            modelDir.appendingPathComponent(modelName, isDirectory: true),
        ]

        return candidates.first { isUsableModelFolder($0) }
    }

    private static func isUsableModelFolder(_ url: URL) -> Bool {
        let requiredItems = [
            "config.json",
            "MelSpectrogram.mlmodelc",
            "AudioEncoder.mlmodelc",
            "TextDecoder.mlmodelc",
        ]

        return requiredItems.allSatisfy {
            FileManager.default.fileExists(atPath: url.appendingPathComponent($0).path)
        }
    }

    // MARK: - Text Cleaning

    static func cleanTranscriptText(_ text: String) -> String {
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
