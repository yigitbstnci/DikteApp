import Foundation
import AVFoundation
import WhisperKit

/// Transcribes audio files using WhisperKit (offline, on-device).
actor TranscriptionService {

    private var whisperKit: WhisperKit?
    private var loadingTask: Task<WhisperKit, Error>?
    private var loadedModelName: String?

    private static let normalizedSampleRate: Double = 16000
    private static let normalizedChannels: AVAudioChannelCount = 1

    func preload(modelName: String) async throws {
        _ = try await loadWhisperKit(modelName: modelName)
    }

    func transcribe(
        audioFileURL: URL,
        modelName: String,
        language: String,
        requiresWordTimestamps: Bool,
        sessionID: String? = nil
    ) async throws -> [TranscriptSegment] {
        let whisper = try await loadWhisperKit(modelName: modelName)
        let audioDuration = Self.audioDuration(of: audioFileURL)
        let byteCount = Self.fileSize(of: audioFileURL)

        let totalStart = Date()

        let prepStart = Date()
        let (processedURL, didNormalize, sourceFormat) = Self.prepareAudioForTranscription(audioFileURL)
        let prepElapsed = Date().timeIntervalSince(prepStart)

        let primaryOptions = DecodingOptions(
            language: language,
            wordTimestamps: requiresWordTimestamps,
            suppressBlank: false
        )

        let fallbackOptions = DecodingOptions(
            language: language,
            wordTimestamps: false,
            suppressBlank: false,
            firstTokenLogProbThreshold: nil,
            noSpeechThreshold: nil
        )

        DikteLog.action("stt", "transcribe.start", "Whisper transkripsiyonu başladı.", metadata: DikteLog.metadata([
            "audio_duration_s": String(format: "%.2f", audioDuration),
            "bytes": byteCount,
            "file": audioFileURL.lastPathComponent,
            "language": language,
            "model": modelName,
            "word_timestamps": requiresWordTimestamps,
            "audio_normalized": didNormalize,
            "source_sample_rate_hz": Int(sourceFormat.sampleRate),
            "source_channels": sourceFormat.channelCount,
            "normalized_sample_rate_hz": Self.normalizedSampleRate,
            "normalized_channels": Self.normalizedChannels,
            "prep_elapsed_s": String(format: "%.3f", prepElapsed)
        ], sessionID: sessionID))

        let primaryStart = Date()
        let results = try await whisper.transcribe(
            audioPath: processedURL.path,
            decodeOptions: primaryOptions
        )
        let primaryElapsed = Date().timeIntervalSince(primaryStart)

        Self.logResults(results, event: "transcribe.primary", sessionID: sessionID, elapsed: primaryElapsed, wordTimestamps: requiresWordTimestamps)
        var segments = Self.makeTranscriptSegments(from: results, audioDuration: audioDuration)

        var fallbackElapsed: TimeInterval = 0

        if segments.isEmpty {
            DikteLog.warning("stt", "transcribe.retry", "Segment bulunamadı; düz transkripsiyon modunda tekrar deneniyor.", metadata: DikteLog.metadata([
                "word_timestamps": false
            ], sessionID: sessionID))

            let fbStart = Date()
            let fallbackResults = try await whisper.transcribe(
                audioPath: processedURL.path,
                decodeOptions: fallbackOptions
            )
            fallbackElapsed = Date().timeIntervalSince(fbStart)

            Self.logResults(fallbackResults, event: "transcribe.fallback", sessionID: sessionID, elapsed: fallbackElapsed, wordTimestamps: false)
            segments = Self.makeTranscriptSegments(from: fallbackResults, audioDuration: audioDuration)
        }

        if didNormalize && processedURL != audioFileURL {
            try? FileManager.default.removeItem(at: processedURL)
        }

        let totalElapsed = Date().timeIntervalSince(totalStart)
        let decodeElapsed = primaryElapsed + fallbackElapsed
        let rtf = audioDuration > 0 ? decodeElapsed / audioDuration : 0

        DikteLog.action("stt", "transcribe.complete", "Transkripsiyon tamamlandı.", metadata: DikteLog.metadata([
            "total_elapsed_s": String(format: "%.2f", totalElapsed),
            "decode_elapsed_s": String(format: "%.2f", decodeElapsed),
            "primary_elapsed_s": String(format: "%.2f", primaryElapsed),
            "model_wait_elapsed_s": String(format: "%.2f", totalElapsed - decodeElapsed),
            "fallback_elapsed_s": String(format: "%.2f", fallbackElapsed),
            "audio_normalized": didNormalize,
            "rtf": String(format: "%.2f", rtf),
            "segments": segments.count
        ], sessionID: sessionID))

        return segments
    }

    static func prepareAudioForTranscription(_ url: URL) -> (URL, Bool, AVAudioFormat) {
        guard let sourceFile = try? AVAudioFile(forReading: url) else {
            return (url, false, AVAudioFormat())
        }

        let sourceFormat = sourceFile.processingFormat
        let needsConversion = sourceFormat.sampleRate != normalizedSampleRate || sourceFormat.channelCount != normalizedChannels

        if !needsConversion {
            return (url, false, sourceFormat)
        }

        guard let normalizedURL = try? normalizeAudio(to: url, targetSampleRate: normalizedSampleRate, targetChannels: normalizedChannels) else {
            return (url, false, sourceFormat)
        }

        return (normalizedURL, true, sourceFormat)
    }

    private static func normalizeAudio(to sourceURL: URL, targetSampleRate: Double, targetChannels: AVAudioChannelCount) throws -> URL {
        let sourceFile = try AVAudioFile(forReading: sourceURL)
        let sourceFormat = sourceFile.processingFormat

        guard let targetFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: targetSampleRate,
            channels: targetChannels,
            interleaved: false
        ) else {
            throw TranscriptionError.converterCreationFailed
        }

        guard let converter = AVAudioConverter(from: sourceFormat, to: targetFormat) else {
            throw TranscriptionError.converterCreationFailed
        }

        let outputFileName = "dikte_normalized_\(UUID().uuidString).wav"
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(outputFileName)

        guard let outputFile = try? AVAudioFile(
            forWriting: outputURL,
            settings: [
                AVFormatIDKey: kAudioFormatLinearPCM,
                AVSampleRateKey: targetSampleRate,
                AVNumberOfChannelsKey: targetChannels,
                AVLinearPCMBitDepthKey: 32,
                AVLinearPCMIsFloatKey: true,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsNonInterleaved: false
            ],
            commonFormat: .pcmFormatFloat32,
            interleaved: false
        ) else {
            throw TranscriptionError.bufferAllocationFailed
        }

        let sourceFrameCount = AVAudioFrameCount(sourceFile.length)
        let frameCount = AVAudioFrameCount(Double(sourceFile.length) / sourceFormat.sampleRate * targetSampleRate)

        guard let inputBuffer = AVAudioPCMBuffer(pcmFormat: sourceFormat, frameCapacity: sourceFrameCount),
              let outputBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: frameCount) else {
            throw TranscriptionError.bufferAllocationFailed
        }

        try sourceFile.read(into: inputBuffer)

        var error: NSError?
        var inputPresented = false
        let status = converter.convert(to: outputBuffer, error: &error) { _, outStatus in
            if inputPresented {
                outStatus.pointee = .noDataNow
                return nil
            }
            outStatus.pointee = .haveData
            inputPresented = true
            return inputBuffer
        }

        if status == .error || error != nil {
            throw error ?? TranscriptionError.conversionFailed
        }

        try outputFile.write(from: outputBuffer)

        return outputURL
    }

    private static func logResults(_ results: [TranscriptionResult], event: String, sessionID: String?, elapsed: TimeInterval, wordTimestamps: Bool) {
        let rawSegmentCount = results.reduce(0) { $0 + $1.segments.count }
        let textCharacterCount = results.reduce(0) { $0 + cleanTranscriptText($1.text).count }
        DikteLog.info("stt", event, "Whisper sonucu alındı.", metadata: DikteLog.metadata([
            "raw_segments": rawSegmentCount,
            "results": results.count,
            "text_chars": textCharacterCount,
            "decode_elapsed_s": String(format: "%.2f", elapsed),
            "word_timestamps": wordTimestamps
        ], sessionID: sessionID))
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

    // MARK: - Model Loading

    private static let modelStorageDir: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("Dikte/Models", isDirectory: true)
    }()

    private func loadWhisperKit(modelName: String) async throws -> WhisperKit {
        if let whisperKit, loadedModelName == modelName {
            return whisperKit
        }

        if let loadingTask {
            return try await loadingTask.value
        }

        let task = Task {
            try await Self.makeWhisperKit(modelName: modelName)
        }
        loadingTask = task

        do {
            let loaded = try await task.value
            whisperKit = loaded
            loadedModelName = modelName
            loadingTask = nil
            return loaded
        } catch {
            loadingTask = nil
            throw error
        }
    }

    func reloadModel(modelName: String) async throws {
        whisperKit = nil
        loadedModelName = nil
        _ = try await loadWhisperKit(modelName: modelName)
    }

    private static func makeWhisperKit(modelName: String, sessionID: String? = nil) async throws -> WhisperKit {
        let modelDir = modelStorageDir
        try FileManager.default.createDirectory(at: modelDir, withIntermediateDirectories: true)

        let cachedFolder = cachedModelFolder(in: modelDir, modelName: modelName)
        DikteLog.action("stt", "model.load", cachedFolder == nil ? "Model indiriliyor." : "Model cache'den yükleniyor.", metadata: DikteLog.metadata([
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

    static func cachedModelFolder(in modelDir: URL, modelName: String) -> URL? {
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
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return cleaned }

        if let regex = try? NSRegularExpression(pattern: #"<\|[^|]*\|>"#) {
            cleaned = regex.stringByReplacingMatches(
                in: cleaned,
                range: NSRange(cleaned.startIndex..., in: cleaned),
                withTemplate: ""
            )
        }

        cleaned = Self.removeTrailingHallucinations(cleaned)

        if let regex = try? NSRegularExpression(pattern: #"\s+"#) {
            cleaned = regex.stringByReplacingMatches(
                in: cleaned,
                range: NSRange(cleaned.startIndex..., in: cleaned),
                withTemplate: " "
            )
        }

        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func removeTrailingHallucinations(_ text: String) -> String {
        let trailingHallucinations = [
            "altyazı m.k.", "altyazılar m.k.", "alt yazı m.k.",
            "altyazı:", "çeviri:", "altyazı çeviri",
            "abone ol", "beğen",
            "www.", ".com",
        ]

        let result = text

        for hallucination in trailingHallucinations {
            if result.lowercased() == hallucination {
                return ""
            }

            let suffixPatterns = [
                " \(hallucination)",
                ".\(hallucination)",
                ",\(hallucination)",
                "!\(hallucination)",
                "?\(hallucination)",
            ]

            for pattern in suffixPatterns {
                if result.lowercased().hasSuffix(pattern) {
                    let prefixEnd = result.count - pattern.count
                    let prefix = String(result.prefix(prefixEnd)).trimmingCharacters(in: .whitespacesAndNewlines)
                    if !prefix.isEmpty {
                        return prefix
                    }
                }
            }

            if result.lowercased().hasSuffix(hallucination) {
                let prefixEnd = result.count - hallucination.count
                let prefix = String(result.prefix(prefixEnd)).trimmingCharacters(in: .whitespacesAndNewlines)
                if !prefix.isEmpty {
                    return prefix
                }
            }
        }

        return result
    }
}

private enum TranscriptionError: LocalizedError {
    case converterCreationFailed
    case bufferAllocationFailed
    case conversionFailed

    var errorDescription: String? {
        switch self {
        case .converterCreationFailed:
            return "Audio converter oluşturulamadı."
        case .bufferAllocationFailed:
            return "Audio buffer ayrılamadı."
        case .conversionFailed:
            return "Audio dönüşümü başarısız."
        }
    }
}
