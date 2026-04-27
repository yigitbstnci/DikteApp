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
