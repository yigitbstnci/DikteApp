import Foundation
import Observation

// MARK: - Whisper Model

struct WhisperModel: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let displayName: String
    let approxSizeMB: Int

    static let defaultModelID = "openai_whisper-large-v3_turbo"

    static let availableModels: [WhisperModel] = [
        WhisperModel(
            id: "openai_whisper-large-v3_turbo",
            name: "openai_whisper-large-v3_turbo",
            displayName: "Whisper Large v3 Turbo",
            approxSizeMB: 954
        ),
        WhisperModel(
            id: "openai_whisper-small",
            name: "openai_whisper-small",
            displayName: "Whisper Small",
            approxSizeMB: 461
        ),
        WhisperModel(
            id: "openai_whisper-base",
            name: "openai_whisper-base",
            displayName: "Whisper Base",
            approxSizeMB: 140
        )
    ]

    static func model(for id: String) -> WhisperModel? {
        availableModels.first { $0.id == id }
    }

    static var defaultModel: WhisperModel {
        model(for: defaultModelID) ?? availableModels[0]
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
        DictationLanguage(id: "ar", code: "ar", displayName: "Arapça"),
    ]

    static func language(for code: String) -> DictationLanguage? {
        supportedLanguages.first { $0.code == code }
    }
}

// MARK: - History Retention Option

enum HistoryRetentionOption: String, CaseIterable, Sendable {
    case oneDay = "1"
    case sevenDays = "7"
    case thirtyDays = "30"
    case unlimited = "0"

    var days: Int? {
        switch self {
        case .oneDay: return 1
        case .sevenDays: return 7
        case .thirtyDays: return 30
        case .unlimited: return nil
        }
    }

    var displayName: String {
        switch self {
        case .oneDay: return "1 gün"
        case .sevenDays: return "7 gün"
        case .thirtyDays: return "30 gün"
        case .unlimited: return "Sınırsız"
        }
    }
}

// MARK: - App Settings Persistence

private enum SettingsKey {
    static let whisperModelID = "dikte.whisperModelID"
    static let dictationLanguageCode = "dikte.dictationLanguageCode"
    static let historyRetentionOption = "dikte.historyRetentionOption"
}

@Observable
final class AppSettings {
    var whisperModelID: String {
        didSet { UserDefaults.standard.set(whisperModelID, forKey: SettingsKey.whisperModelID) }
    }

    var dictationLanguageCode: String {
        didSet { UserDefaults.standard.set(dictationLanguageCode, forKey: SettingsKey.dictationLanguageCode) }
    }

    var historyRetentionOption: HistoryRetentionOption {
        didSet {
            UserDefaults.standard.set(historyRetentionOption.rawValue, forKey: SettingsKey.historyRetentionOption)
        }
    }

    init() {
        let storedModelID = UserDefaults.standard.string(forKey: SettingsKey.whisperModelID) ?? WhisperModel.defaultModelID
        if let storedModel = WhisperModel.model(for: storedModelID) {
            self.whisperModelID = storedModel.id
        } else {
            self.whisperModelID = WhisperModel.defaultModelID
        }

        let storedLanguageCode = UserDefaults.standard.string(forKey: SettingsKey.dictationLanguageCode) ?? "tr"
        self.dictationLanguageCode = DictationLanguage.language(for: storedLanguageCode)?.code ?? "tr"

        let storedRetentionRaw = UserDefaults.standard.string(forKey: SettingsKey.historyRetentionOption) ?? HistoryRetentionOption.sevenDays.rawValue
        self.historyRetentionOption = HistoryRetentionOption(rawValue: storedRetentionRaw) ?? .sevenDays

        UserDefaults.standard.set(whisperModelID, forKey: SettingsKey.whisperModelID)
        UserDefaults.standard.set(dictationLanguageCode, forKey: SettingsKey.dictationLanguageCode)
        UserDefaults.standard.set(historyRetentionOption.rawValue, forKey: SettingsKey.historyRetentionOption)
    }

    var selectedModel: WhisperModel {
        WhisperModel.model(for: whisperModelID) ?? WhisperModel.defaultModel
    }

    var selectedLanguage: DictationLanguage {
        DictationLanguage.language(for: dictationLanguageCode) ?? DictationLanguage.supportedLanguages[0]
    }

    func resetToDefaults() {
        whisperModelID = WhisperModel.defaultModelID
        dictationLanguageCode = "tr"
        historyRetentionOption = .sevenDays
    }
}
