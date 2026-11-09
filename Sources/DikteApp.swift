import SwiftUI
import AppKit

/// Dikte — Menu Bar only macOS app.
/// LSUIElement = true in Info.plist hides the Dock icon.
@main
struct DikteApp: App {
    @State private var appState = AppState()
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environment(appState)
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
                    appState.releaseAudioRouting()
                }
        } label: {
            Image(systemName: appState.isRecording ? "record.circle.fill" : "mic.badge.plus")
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    appState.isRecording ? .red : .primary,
                    appState.isRecording ? .red : .secondary
                )
        }
        .menuBarExtraStyle(.menu)
        .onChange(of: appState.isRecording) { _, isRecording in
            if isRecording {
                FloatingHUDManager.shared.showHUD(appState: appState)
            }
        }
        .onChange(of: appState.showResult) { _, showResult in
            if showResult {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    appState.showResult = false
                    if !appState.isRecording && !appState.isProcessing && appState.processingError == nil {
                        FloatingHUDManager.shared.hideHUD()
                    }
                }
            } else if !appState.isRecording && !appState.isProcessing && appState.processingError == nil {
                FloatingHUDManager.shared.hideHUD()
            }
        }
        .onChange(of: appState.modelReadyState) { _, newState in
            switch newState {
            case .preparing:
                FloatingHUDManager.shared.showHUD(appState: appState)
            case .ready:
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    if !appState.isRecording && !appState.isProcessing && !appState.showResult && appState.processingError == nil {
                        FloatingHUDManager.shared.hideHUD()
                    }
                }
            case .failed:
                FloatingHUDManager.shared.showHUD(appState: appState)
            }
        }
        .onChange(of: appState.processingError) { _, newError in
            if newError != nil {
                FloatingHUDManager.shared.showHUD(appState: appState)
            }
        }

        Window("Kayıt Kısayolu", id: RecordingShortcutSettingsView.windowID) {
            RecordingShortcutSettingsView()
                .environment(appState)
        }
        .defaultPosition(.center)
        .defaultLaunchBehavior(.suppressed)
        .windowResizability(.contentSize)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
