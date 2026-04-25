import SwiftUI
import KeyboardShortcuts

/// Settings window for configuring the global keyboard shortcut.
struct SettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Kayıt Kısayolu:")
                    Spacer()
                    KeyboardShortcuts.Recorder("", name: .toggleRecording)
                }
            } header: {
                Label("Klavye Kısayolu", systemImage: "keyboard")
            } footer: {
                Text("Bu kısayol ile herhangi bir uygulamadayken kaydı başlatıp durdurabilirsiniz.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                LabeledContent("Sürüm", value: "1.0.0 (MVP)")
                LabeledContent("Motor", value: "WhisperKit (Çevrimdışı)")
            } header: {
                Label("Hakkında", systemImage: "info.circle")
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 220)
    }
}
