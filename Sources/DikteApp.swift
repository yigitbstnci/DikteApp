import SwiftUI
import KeyboardShortcuts

/// Dikte — Menu Bar only macOS app.
/// LSUIElement = true in Info.plist hides the Dock icon.
@main
struct DikteApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environment(appState)
        } label: {
            // Menu bar icon changes based on recording state
            Image(systemName: appState.isRecording ? "record.circle.fill" : "mic.badge.plus")
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    appState.isRecording ? .red : .primary,
                    appState.isRecording ? .red : .secondary
                )
        }
        .menuBarExtraStyle(.window)

        // Settings window for keyboard shortcut configuration
        Settings {
            SettingsView()
                .environment(appState)
        }
    }
}
