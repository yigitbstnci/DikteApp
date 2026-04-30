import XCTest
@testable import Dikte

final class AppSettingsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "dikte.whisperModelID")
        UserDefaults.standard.removeObject(forKey: "dikte.dictationLanguageCode")
    }

    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: "dikte.whisperModelID")
        UserDefaults.standard.removeObject(forKey: "dikte.dictationLanguageCode")
    }

    func testDefaultValues() {
        let settings = AppSettings()

        XCTAssertEqual(settings.whisperModelID, WhisperModel.defaultModelID)
        XCTAssertEqual(settings.dictationLanguageCode, "tr")
    }

    func testPersistenceRoundTrip() {
        let settings = AppSettings()
        settings.whisperModelID = "openai_whisper-base"
        settings.dictationLanguageCode = "en"

        let reloaded = AppSettings()

        XCTAssertEqual(reloaded.whisperModelID, "openai_whisper-base")
        XCTAssertEqual(reloaded.dictationLanguageCode, "en")
    }

    func testSelectedModelReturnsCorrectModel() {
        let settings = AppSettings()
        settings.whisperModelID = "openai_whisper-base"

        XCTAssertEqual(settings.selectedModel.id, "openai_whisper-base")
        XCTAssertEqual(settings.selectedModel.name, "openai_whisper-base")
    }

    func testSelectedLanguageReturnsCorrectLanguage() {
        let settings = AppSettings()
        settings.dictationLanguageCode = "en"

        XCTAssertEqual(settings.selectedLanguage.code, "en")
        XCTAssertEqual(settings.selectedLanguage.displayName, "İngilizce")
    }

    func testAvailableModelsContainOnlyWhisperKitModels() {
        XCTAssertEqual(WhisperModel.availableModels.map(\.id), [
            "openai_whisper-large-v3_turbo",
            "openai_whisper-small",
            "openai_whisper-base"
        ])
    }

    func testResetToDefaults() {
        let settings = AppSettings()
        settings.whisperModelID = "openai_whisper-base"
        settings.dictationLanguageCode = "en"

        settings.resetToDefaults()

        XCTAssertEqual(settings.whisperModelID, WhisperModel.defaultModelID)
        XCTAssertEqual(settings.dictationLanguageCode, "tr")
    }

    func testInvalidStoredModelFallsBackToDefaultModel() {
        UserDefaults.standard.set("missing-model", forKey: "dikte.whisperModelID")

        let settings = AppSettings()

        XCTAssertEqual(settings.whisperModelID, WhisperModel.defaultModelID)
        XCTAssertEqual(settings.selectedModel.id, WhisperModel.defaultModelID)
    }

    func testInvalidStoredLanguageFallsBackToTurkish() {
        UserDefaults.standard.set("zz", forKey: "dikte.dictationLanguageCode")

        let settings = AppSettings()

        XCTAssertEqual(settings.dictationLanguageCode, "tr")
    }
}
