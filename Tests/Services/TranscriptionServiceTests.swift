import XCTest
import AVFoundation
@testable import Dikte

final class TranscriptionServiceTests: XCTestCase {
    func testCachedModelFolderFindsWhisperKitHubCacheLayout() throws {
        let root = try makeTemporaryDirectory()
        let modelFolder = root.appendingPathComponent(
            "models/argmaxinc/whisperkit-coreml/openai_whisper-large-v3_turbo",
            isDirectory: true
        )
        try createUsableModelFolder(at: modelFolder)

        XCTAssertEqual(TranscriptionService.cachedModelFolder(in: root), modelFolder)
    }

    func testCachedModelFolderIgnoresIncompleteModelFolder() throws {
        let root = try makeTemporaryDirectory()
        let modelFolder = root.appendingPathComponent(
            "models/argmaxinc/whisperkit-coreml/openai_whisper-large-v3_turbo",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: modelFolder, withIntermediateDirectories: true)
        try Data().write(to: modelFolder.appendingPathComponent("config.json"))

        XCTAssertNil(TranscriptionService.cachedModelFolder(in: root))
    }

    // MARK: - Text Cleaning Tests

    func testCleanRemovesAltyazıHallucinations() {
        let inputs = [
            "Altyazı M.K.",
            "Altyazılar M.K.",
            "Alt yazı M.K.",
            "Altyazı:",
            "Çeviri:",
            "Altyazı çeviri"
        ]

        for input in inputs {
            let result = TranscriptionService.cleanTranscriptText(input)
            XCTAssertEqual(result, "", "Failed for: \(input)")
        }
    }

    func testCleanRemovesWebHallucinations() {
        XCTAssertEqual(TranscriptionService.cleanTranscriptText("www.example.com"), "www.example")
        XCTAssertEqual(TranscriptionService.cleanTranscriptText(".com"), "")
    }

    func testCleanRemovesTrailingHallucinations() {
        XCTAssertEqual(TranscriptionService.cleanTranscriptText("Test sentence abone ol"), "Test sentence")
        XCTAssertEqual(TranscriptionService.cleanTranscriptText("Test sentence. Abone ol"), "Test sentence.")
        XCTAssertEqual(TranscriptionService.cleanTranscriptText("Test sentence, beğen"), "Test sentence,")
        XCTAssertEqual(TranscriptionService.cleanTranscriptText("abone ol"), "")
        XCTAssertEqual(TranscriptionService.cleanTranscriptText("Altyazı M.K."), "")
        XCTAssertEqual(TranscriptionService.cleanTranscriptText("Alt yazı M.K."), "")
        XCTAssertEqual(TranscriptionService.cleanTranscriptText("Beğen"), "")
    }

    func testCleanPreservesMidSentenceHallucinations() {
        XCTAssertEqual(TranscriptionService.cleanTranscriptText("Kullanıcıya abone ol butonunu göster"), "Kullanıcıya abone ol butonunu göster")
        XCTAssertEqual(TranscriptionService.cleanTranscriptText("Burada beğen kelimesi geçiyor"), "Burada beğen kelimesi geçiyor")
        XCTAssertEqual(TranscriptionService.cleanTranscriptText("Alt yazı dosyasını aç"), "Alt yazı dosyasını aç")
        XCTAssertEqual(TranscriptionService.cleanTranscriptText("Çeviri: bu metin"), "Çeviri: bu metin")
        XCTAssertEqual(TranscriptionService.cleanTranscriptText("Altyazı M.K. test"), "Altyazı M.K. test")
    }

    func testCleanNormalizesWhitespace() {
        let input = "Test    multiple   spaces   here"
        let result = TranscriptionService.cleanTranscriptText(input)
        XCTAssertFalse(result.contains("    "))
        XCTAssertEqual(result.components(separatedBy: " ").filter { !$0.isEmpty }.count, 4)
    }

    func testCleanTrimsWhitespaceAndNewlines() {
        let input = "   \n\t  Test content  \n\t  "
        let result = TranscriptionService.cleanTranscriptText(input)
        XCTAssertEqual(result, "Test content")
        XCTAssertFalse(result.hasPrefix(" "))
        XCTAssertFalse(result.hasSuffix(" "))
        XCTAssertFalse(result.hasPrefix("\n"))
        XCTAssertFalse(result.hasSuffix("\n"))
    }

    func testCleanRemovesSpecialTokens() {
        let inputs = [
            "<|123|>test<|456|>",
            "<|en|>test<|zh|>",
            "text<|skip|>more"
        ]

        for input in inputs {
            let result = TranscriptionService.cleanTranscriptText(input)
            XCTAssertFalse(result.contains("<|"), "Failed for: \(input)")
            XCTAssertFalse(result.contains("|>"), "Failed for: \(input)")
        }
    }

    func testCleanReturnsEmptyForOnlyWhitespaceInput() {
        let inputs = ["", "   ", "\n\t", "\t\n   "]

        for input in inputs {
            let result = TranscriptionService.cleanTranscriptText(input)
            XCTAssertEqual(result, "", "Failed for input: \(input)")
        }
    }

    func testCleanPreservesNormalText() {
        let input = "Normal speech transcription with normal words."
        let result = TranscriptionService.cleanTranscriptText(input)
        XCTAssertEqual(result, input)
    }

    private func makeTemporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("dikte-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func createUsableModelFolder(at url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        try Data().write(to: url.appendingPathComponent("config.json"))

        for directoryName in ["MelSpectrogram.mlmodelc", "AudioEncoder.mlmodelc", "TextDecoder.mlmodelc"] {
            try FileManager.default.createDirectory(
                at: url.appendingPathComponent(directoryName, isDirectory: true),
                withIntermediateDirectories: true
            )
        }
    }

    // MARK: - Audio Normalization Tests

    func testPrepareAudioSkipsNormalizationForCompatibleAudio() throws {
        let dir = try makeTemporaryDirectory()
        let audioURL = dir.appendingPathComponent("test_16k_mono.wav")

        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 16000,
            channels: 1,
            interleaved: false
        )!
        let file = try AVAudioFile(forWriting: audioURL, settings: format.settings, commonFormat: .pcmFormatFloat32, interleaved: false)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 100)!
        buffer.frameLength = 100
        try file.write(from: buffer)

        let (resultURL, didNormalize, sourceFormat) = TranscriptionService.prepareAudioForTranscription(audioURL)

        XCTAssertEqual(resultURL, audioURL)
        XCTAssertFalse(didNormalize)
        XCTAssertEqual(sourceFormat.sampleRate, 16000)
        XCTAssertEqual(sourceFormat.channelCount, 1)
    }

    func testPrepareAudioNormalizes48kHzStereo() throws {
        let dir = try makeTemporaryDirectory()
        let audioURL = dir.appendingPathComponent("test_48k_stereo.wav")

        let sourceFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 48000,
            channels: 2,
            interleaved: false
        )!
        let buffer = AVAudioPCMBuffer(pcmFormat: sourceFormat, frameCapacity: 100)!
        buffer.frameLength = 100

        if let file = try? AVAudioFile(forWriting: audioURL, settings: [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 48000,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 32,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]) {
            try file.write(from: buffer)
        }

        let (resultURL, didNormalize, sourceFormatReturned) = TranscriptionService.prepareAudioForTranscription(audioURL)

        XCTAssertNotEqual(resultURL, audioURL)
        XCTAssertTrue(didNormalize)
        XCTAssertEqual(sourceFormatReturned.sampleRate, 48000)
        XCTAssertEqual(sourceFormatReturned.channelCount, 2)

        try? FileManager.default.removeItem(at: resultURL)
    }

    func testPrepareAudioReturnsOriginalOnInvalidFile() throws {
        let dir = try makeTemporaryDirectory()
        let audioURL = dir.appendingPathComponent("invalid_audio.txt")
        try "not audio data".write(to: audioURL, atomically: true, encoding: .utf8)

        let (resultURL, didNormalize, _) = TranscriptionService.prepareAudioForTranscription(audioURL)

        XCTAssertEqual(resultURL, audioURL)
        XCTAssertFalse(didNormalize)
    }
}
