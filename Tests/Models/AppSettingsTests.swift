import XCTest
@testable import Dikte

final class AppSettingsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "dikte.transcriptionProvider")
        UserDefaults.standard.removeObject(forKey: "dikte.whisperModelID")
        UserDefaults.standard.removeObject(forKey: "dikte.dictationLanguageCode")
    }

    override func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: "dikte.transcriptionProvider")
        UserDefaults.standard.removeObject(forKey: "dikte.whisperModelID")
        UserDefaults.standard.removeObject(forKey: "dikte.dictationLanguageCode")
    }

    func testDefaultValues() {
        let settings = AppSettings()

        XCTAssertEqual(settings.transcriptionProvider, .whisperKit)
        XCTAssertEqual(settings.whisperModelID, WhisperModel.defaultModelID)
        XCTAssertEqual(settings.dictationLanguageCode, "tr")
    }

    func testPersistenceRoundTrip() {
        let settings = AppSettings()
        settings.transcriptionProvider = .whisperKit
        settings.whisperModelID = "openai_whisper-base"
        settings.dictationLanguageCode = "en"

        let reloaded = AppSettings()

        XCTAssertEqual(reloaded.transcriptionProvider, .whisperKit)
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

    func testAvailableModelsForSelectedProviderFiltersCorrectly() {
        let settings = AppSettings()
        settings.transcriptionProvider = .whisperKit

        let models = settings.availableModelsForSelectedProvider
        XCTAssertTrue(models.allSatisfy { $0.requiredProvider == .whisperKit })
    }

    func testFasterWhisperProviderIsNotAvailable() {
        XCTAssertFalse(TranscriptionProvider.fasterWhisper.isAvailable)
    }

    func testWhisperKitProviderIsAvailable() {
        XCTAssertTrue(TranscriptionProvider.whisperKit.isAvailable)
    }

    func testResetToDefaults() {
        let settings = AppSettings()
        settings.transcriptionProvider = .fasterWhisper
        settings.whisperModelID = "openai_whisper-base"
        settings.dictationLanguageCode = "en"

        settings.resetToDefaults()

        XCTAssertEqual(settings.transcriptionProvider, .whisperKit)
        XCTAssertEqual(settings.whisperModelID, WhisperModel.defaultModelID)
        XCTAssertEqual(settings.dictationLanguageCode, "tr")
    }

    func testUnavailableStoredProviderFallsBackToWhisperKit() {
        UserDefaults.standard.set(TranscriptionProvider.fasterWhisper.rawValue, forKey: "dikte.transcriptionProvider")

        let settings = AppSettings()

        XCTAssertEqual(settings.transcriptionProvider, .whisperKit)
    }

    func testInvalidStoredModelFallsBackToDefaultModel() {
        UserDefaults.standard.set("missing-model", forKey: "dikte.whisperModelID")

        let settings = AppSettings()

        XCTAssertEqual(settings.whisperModelID, WhisperModel.defaultModelID)
        XCTAssertEqual(settings.selectedModel.id, WhisperModel.defaultModelID)
    }

    func testStoredFasterWhisperModelFallsBackToDefaultModel() {
        UserDefaults.standard.set("faster-whisper-large-v3-turbo", forKey: "dikte.whisperModelID")

        let settings = AppSettings()

        XCTAssertEqual(settings.whisperModelID, WhisperModel.defaultModelID)
    }

    func testInvalidStoredLanguageFallsBackToTurkish() {
        UserDefaults.standard.set("zz", forKey: "dikte.dictationLanguageCode")

        let settings = AppSettings()

        XCTAssertEqual(settings.dictationLanguageCode, "tr")
    }
}
