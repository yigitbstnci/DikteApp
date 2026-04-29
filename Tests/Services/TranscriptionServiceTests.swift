import XCTest
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
            "Altyazı M.K. test",
            "Altyazılar M.K. test",
            "Alt yazı M.K. test",
            "Altyazı: test",
            "Çeviri: test",
            "Altyazı çeviri test"
        ]

        for input in inputs {
            let result = TranscriptionService.cleanTranscriptText(input)
            XCTAssertFalse(result.contains("Altyazı"), "Failed for: \(input)")
            XCTAssertFalse(result.contains("M.K."), "Failed for: \(input)")
            XCTAssertFalse(result.contains("Çeviri"), "Failed for: \(input)")
        }
    }

    func testCleanRemovesWebHallucinations() {
        let inputs = [
            "Visit www.example.com for more",
            "Check example.com for info",
            "Don not forget to subscribe",
            "Hit the like button",
            "Visit www.example.com and subscribe"
        ]

        for input in inputs {
            let result = TranscriptionService.cleanTranscriptText(input)
            XCTAssertFalse(result.contains("www."), "Failed for: \(input)")
            XCTAssertFalse(result.contains(".com"), "Failed for: \(input)")
            XCTAssertFalse(result.contains("Abone ol"), "Failed for: \(input)")
            XCTAssertFalse(result.contains("Beğen"), "Failed for: \(input)")
        }
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
}
