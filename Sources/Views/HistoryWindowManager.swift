import Cocoa
import SwiftUI

@MainActor
class HistoryWindowManager: NSObject {
    static let shared = HistoryWindowManager()

    private var window: NSWindow?

    func showWindow(appState: AppState) {
        if window == nil {
            let panel = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 800, height: 540),
                styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView, .resizable],
                backing: .buffered,
                defer: false
            )

            panel.title = "Dikte Geçmişi"
            panel.titlebarAppearsTransparent = true
            panel.titleVisibility = .hidden
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = true
            panel.isReleasedWhenClosed = false
            panel.minSize = NSSize(width: 680, height: 480)
            panel.setFrameAutosaveName("DikteHistoryWindow")
            panel.center()
            panel.delegate = self

            let hostingView = NSHostingView(rootView: HistoryView().environment(appState))
            panel.contentView = hostingView

            self.window = panel
        }

        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension HistoryWindowManager: NSWindowDelegate {
    nonisolated func windowWillClose(_ notification: Notification) {
        Task { @MainActor in
            self.window = nil
        }
    }
}
