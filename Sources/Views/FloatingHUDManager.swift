import Cocoa
import SwiftUI

@MainActor
class FloatingHUDManager {
    static let shared = FloatingHUDManager()
    
    private var window: NSPanel?
    
    func showHUD(appState: AppState) {
        if window == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 320, height: 800),
                styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
                backing: .buffered,
                defer: false
            )
            
            panel.isFloatingPanel = true
            panel.level = .floating
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = false
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            
            // Allow clicks to pass through except where SwiftUI content catches it
            panel.ignoresMouseEvents = false
            
            let hostingView = NSHostingView(rootView: FloatingHUDView().environment(appState))
            panel.contentView = hostingView
            
            self.window = panel
        }
        
        positionWindow()
        window?.orderFront(nil)
    }
    
    func hideHUD() {
        window?.orderOut(nil)
    }
    
    private func positionWindow() {
        guard let window = window, let screen = NSScreen.main else { return }
        let padding: CGFloat = 20
        let screenRect = screen.visibleFrame
        // Anchor top right
        let x = screenRect.maxX - window.frame.width - padding
        let y = screenRect.maxY - window.frame.height - padding
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
