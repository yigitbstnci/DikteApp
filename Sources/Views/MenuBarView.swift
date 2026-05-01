import SwiftUI
import AppKit

/// Native dropdown content shown when the menu bar icon is clicked.
struct MenuBarView: View {
    @Environment(AppState.self) private var appState

    @State private var selectedModelID: String = ""
    @State private var selectedLanguageCode: String = ""
    @State private var selectedHistoryRetentionOption: HistoryRetentionOption = .sevenDays

    var body: some View {
        Text("Dikte 1.0")
            .font(.system(.body, weight: .semibold))

        Divider()

        Button(action: {
            HistoryWindowManager.shared.showWindow(appState: appState)
        }) {
            Label("Geçmiş", systemImage: "clock.arrow.circlepath")
        }

        Divider()

        Menu {
            dictationItems
        } label: {
            Label("Kayıt", systemImage: dictationMenuIcon)
        }

        Menu {
            clipboardItems
        } label: {
            Label("Pano", systemImage: "doc.on.clipboard")
        }

        Menu {
            settingsItems
        } label: {
            Label("Ayarlar", systemImage: "gearshape")
        }

        Divider()

        Button(action: quit) {
            Label("Çıkış", systemImage: "power")
        }
        .keyboardShortcut("q")
        .onAppear {
            selectedModelID = appState.settings.whisperModelID
            selectedLanguageCode = appState.settings.dictationLanguageCode
            selectedHistoryRetentionOption = appState.settings.historyRetentionOption
        }
        .onChange(of: selectedModelID) { _, newValue in
            appState.setWhisperModelID(newValue)
        }
        .onChange(of: selectedLanguageCode) { _, newValue in
            appState.setDictationLanguageCode(newValue)
        }
        .onChange(of: selectedHistoryRetentionOption) { _, newValue in
            appState.settings.historyRetentionOption = newValue
        }
    }

    @ViewBuilder
    private var dictationItems: some View {
        if appState.isProcessing {
            Label("Yerel olarak işleniyor", systemImage: "hourglass")
        } else {
            Button(action: appState.toggleRecording) {
                Label(recordingActionTitle, systemImage: recordingActionIcon)
            }
        }

        if appState.isRecording {
            Text("Kayıt aktif")
        } else if appState.showResult {
            Text("Sonuç panoda")
        } else {
            Text("Kısayol: ⌘⇧Space")
        }
    }

    @ViewBuilder
    private var clipboardItems: some View {
        if appState.isRecording {
            Label("Aktif", systemImage: "checkmark.circle")
        } else {
            Label("Pasif", systemImage: "pause.circle")
        }

        if let currentSession = appState.currentSession {
            Text("Son oturum: \(currentSession.clipboardItems.count) öğe")
        } else {
            Text("Son oturum yok")
        }
    }

    @ViewBuilder
    private var settingsItems: some View {
        Picker("Model", selection: $selectedModelID) {
            ForEach(WhisperModel.availableModels) { model in
                Text(model.displayName).tag(model.id)
            }
        }

        Picker("Dil", selection: $selectedLanguageCode) {
            ForEach(DictationLanguage.supportedLanguages) { language in
                Text(language.displayName).tag(language.code)
            }
        }

        Picker("Geçmiş Temizliği", selection: $selectedHistoryRetentionOption) {
            ForEach(HistoryRetentionOption.allCases, id: \.self) { option in
                Text(option.displayName).tag(option)
            }
        }
    }

    private var dictationMenuIcon: String {
        if appState.isProcessing {
            return "hourglass"
        }

        return appState.isRecording ? "waveform.circle.fill" : "waveform"
    }

    private var recordingActionTitle: String {
        appState.isRecording ? "Kaydı Durdur" : "Kayıt Başlat"
    }

    private var recordingActionIcon: String {
        appState.isRecording ? "stop.circle" : "mic.circle"
    }

    private func quit() {
        NSApplication.shared.terminate(nil)
    }
}