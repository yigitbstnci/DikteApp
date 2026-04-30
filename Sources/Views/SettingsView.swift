import SwiftUI
import KeyboardShortcuts

struct SettingsView: View {
    @Environment(AppState.self) private var appState

    private var settings: AppSettings { appState.settings }
    private var isBusy: Bool { appState.isRecording || appState.isProcessing }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                shortcutSection
                modelSection
                languageSection
            }
            .padding(16)
        }
    }

    private var shortcutSection: some View {
        GroupBox("Kayıt Kısayolu") {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Kaydı başlat / durdur")
                        .font(.dzButtonText())
                    Text("Recorder'a tıkla, kullanmak istediğin kısayolu bas.")
                        .font(.dzSmallText())
                        .foregroundStyle(.secondary)
                }

                Spacer()
                KeyboardShortcuts.Recorder("", name: .toggleRecording)
            }
            .padding(.vertical, 4)
        }
    }

    private var modelSection: some View {
        GroupBox("Model") {
            VStack(alignment: .leading, spacing: 8) {
                Picker("Model", selection: modelBinding) {
                    ForEach(WhisperModel.availableModels) { model in
                        Text("\(model.displayName) (\(model.approxSizeMB) MB)")
                            .tag(model.id)
                    }
                }
                .pickerStyle(.menu)
                .disabled(isBusy)

                Text(modelHelpText)
                    .font(.dzSmallText())
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    private var languageSection: some View {
        GroupBox("Dikte Dili") {
            VStack(alignment: .leading, spacing: 8) {
                Picker("Dil", selection: languageBinding) {
                    ForEach(DictationLanguage.supportedLanguages) { language in
                        Text(language.displayName)
                            .tag(language.code)
                    }
                }
                .pickerStyle(.menu)
                .disabled(isBusy)

                Text(isBusy ? "Kayıt veya işlem sırasında dil değiştirilemez." : "Seçili dil bir sonraki transkripsiyonda kullanılır.")
                    .font(.dzSmallText())
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    private var modelBinding: Binding<String> {
        Binding(
            get: { settings.whisperModelID },
            set: { appState.setWhisperModelID($0) }
        )
    }

    private var languageBinding: Binding<String> {
        Binding(
            get: { settings.dictationLanguageCode },
            set: { appState.setDictationLanguageCode($0) }
        )
    }

    private var modelHelpText: String {
        if isBusy {
            return "Kayıt veya işlem sırasında model değiştirilemez."
        }

        return "Model değişince Dikte yeni modeli yerel olarak hazırlar."
    }
}
