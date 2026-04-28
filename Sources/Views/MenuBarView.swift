import SwiftUI
import AppKit

/// Native dropdown content shown when the menu bar icon is clicked.
struct MenuBarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Text("Dikte")
        Text(statusText)

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

        Divider()

        Button(action: openSettings) {
            Label("Ayarlar...", systemImage: "gearshape")
        }

        Divider()

        Button(action: quit) {
            Label("Çıkış", systemImage: "power")
        }
        .keyboardShortcut("q")
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
            Text("Süre: \(appState.formattedDuration)")
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

    private var statusText: String {
        if appState.isProcessing {
            return "İşleniyor"
        }

        if appState.isRecording {
            return "Kayıt: \(appState.formattedDuration)"
        }

        if appState.showResult {
            return "Panoya kopyalandı"
        }

        return "Hazır"
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

    private func openSettings() {
        let delivered = NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        DikteLog.action("app", "settings.open.request", "Ayarlar penceresi açma isteği alındı.", metadata: [
            "delivered": delivered,
            "is_processing": appState.isProcessing,
            "is_recording": appState.isRecording,
            "show_result": appState.showResult
        ])
    }

    private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
