import KeyboardShortcuts
import SwiftUI

struct RecordingShortcutSettingsView: View {
    static let windowID = "recording-shortcut-settings"

    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            KeyboardShortcuts.Recorder("Kayıt başlat / durdur", name: .toggleRecording) { _ in
                appState.refreshRecordingShortcut()
            }

            if #available(macOS 27.0, *), appState.recordingShortcut == RecordingShortcut.legacyDefault {
                Label("Bu kısayol Siri ile çakışabilir.", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
            }

            Button("Varsayılana dön", systemImage: "arrow.counterclockwise") {
                KeyboardShortcuts.reset(.toggleRecording)
                appState.refreshRecordingShortcut()
            }
            .disabled(appState.recordingShortcut == RecordingShortcut.defaultShortcut)
        }
        .padding(20)
        .frame(width: 350, alignment: .leading)
    }
}
