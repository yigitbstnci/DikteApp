import Foundation
import Observation

// MARK: - Transcription Provider

enum TranscriptionProvider: String, CaseIterable, Identifiable, Sendable {
    case whisperKit = "whisperkit"
    case fasterWhisper = "faster-whisper"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .whisperKit: return "WhisperKit (Yerel)"
        case .fasterWhisper: return "Faster-Whisper"
        }
    }

    var isAvailable: Bool {
        switch self {
        case .whisperKit: return true
        case .fasterWhisper: return false
        }
    }
}

// MARK: - Whisper Model

struct WhisperModel: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let displayName: String
    let requiredProvider: TranscriptionProvider
    let approxSizeMB: Int

    static let defaultModelID = "openai_whisper-large-v3_turbo"

    static let availableModels: [WhisperModel] = [
        WhisperModel(
            id: "openai_whisper-large-v3_turbo",
            name: "openai_whisper-large-v3_turbo",
            displayName: "Whisper Large v3 Turbo",
            requiredProvider: .whisperKit,
            approxSizeMB: 954
        ),
        WhisperModel(
            id: "openai_whisper-small",
            name: "openai_whisper-small",
            displayName: "Whisper Small",
            requiredProvider: .whisperKit,
            approxSizeMB: 461
        ),
        WhisperModel(
            id: "openai_whisper-base",
            name: "openai_whisper-base",
            displayName: "Whisper Base",
            requiredProvider: .whisperKit,
            approxSizeMB: 140
        ),
        WhisperModel(
            id: "faster-whisper-large-v3-turbo",
            name: "faster-whisper-large-v3-turbo",
            displayName: "Faster-Whisper Large v3 Turbo",
            requiredProvider: .fasterWhisper,
            approxSizeMB: 904
        ),
    ]

    static func model(for id: String) -> WhisperModel? {
        availableModels.first { $0.id == id }
    }

    static var defaultModel: WhisperModel {
        model(for: defaultModelID) ?? availableModels[0]
    }

    static func models(for provider: TranscriptionProvider) -> [WhisperModel] {
        availableModels.filter { $0.requiredProvider == provider }
    }
}

// MARK: - Dictation Language

struct DictationLanguage: Identifiable, Hashable, Sendable {
    let id: String
    let code: String
    let displayName: String

    static let supportedLanguages: [DictationLanguage] = [
        DictationLanguage(id: "tr", code: "tr", displayName: "Türkçe"),
        DictationLanguage(id: "en", code: "en", displayName: "İngilizce"),
        DictationLanguage(id: "de", code: "de", displayName: "Almanca"),
        DictationLanguage(id: "fr", code: "fr", displayName: "Fransızca"),
        DictationLanguage(id: "es", code: "es", displayName: "İspanyolca"),
    ]

    static func language(for code: String) -> DictationLanguage? {
        supportedLanguages.first { $0.code == code }
    }
}

// MARK: - App Settings Persistence

private enum SettingsKey {
    static let transcriptionProvider = "dikte.transcriptionProvider"
    static let whisperModelID = "dikte.whisperModelID"
    static let dictationLanguageCode = "dikte.dictationLanguageCode"
}

@Observable
final class AppSettings {
    var transcriptionProvider: TranscriptionProvider {
        didSet { UserDefaults.standard.set(transcriptionProvider.rawValue, forKey: SettingsKey.transcriptionProvider) }
    }

    var whisperModelID: String {
        didSet { UserDefaults.standard.set(whisperModelID, forKey: SettingsKey.whisperModelID) }
    }

    var dictationLanguageCode: String {
        didSet { UserDefaults.standard.set(dictationLanguageCode, forKey: SettingsKey.dictationLanguageCode) }
    }

    init() {
        let providerRaw = UserDefaults.standard.string(forKey: SettingsKey.transcriptionProvider) ?? TranscriptionProvider.whisperKit.rawValue
        let storedProvider = TranscriptionProvider(rawValue: providerRaw) ?? .whisperKit
        let selectedProvider = storedProvider.isAvailable ? storedProvider : .whisperKit
        self.transcriptionProvider = selectedProvider

        let storedModelID = UserDefaults.standard.string(forKey: SettingsKey.whisperModelID) ?? WhisperModel.defaultModelID
        if let storedModel = WhisperModel.model(for: storedModelID), storedModel.requiredProvider == selectedProvider {
            self.whisperModelID = storedModel.id
        } else {
            self.whisperModelID = WhisperModel.defaultModelID
        }

        let storedLanguageCode = UserDefaults.standard.string(forKey: SettingsKey.dictationLanguageCode) ?? "tr"
        self.dictationLanguageCode = DictationLanguage.language(for: storedLanguageCode)?.code ?? "tr"

        UserDefaults.standard.set(transcriptionProvider.rawValue, forKey: SettingsKey.transcriptionProvider)
        UserDefaults.standard.set(whisperModelID, forKey: SettingsKey.whisperModelID)
        UserDefaults.standard.set(dictationLanguageCode, forKey: SettingsKey.dictationLanguageCode)
    }

    var selectedModel: WhisperModel {
        WhisperModel.model(for: whisperModelID) ?? WhisperModel.defaultModel
    }

    var selectedLanguage: DictationLanguage {
        DictationLanguage.language(for: dictationLanguageCode) ?? DictationLanguage.supportedLanguages[0]
    }

    var availableModelsForSelectedProvider: [WhisperModel] {
        WhisperModel.models(for: transcriptionProvider)
    }

    var canChangeSettings: Bool {
        true
    }

    func resetToDefaults() {
        transcriptionProvider = .whisperKit
        whisperModelID = WhisperModel.defaultModelID
        dictationLanguageCode = "tr"
    }
}
