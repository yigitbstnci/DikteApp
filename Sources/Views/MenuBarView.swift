import SwiftUI

/// Main popover content shown when the menu bar icon is clicked.
/// "Fluid Zen" Edition
struct MenuBarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 24) {
            // Top Section: Title & Settings
            HStack {
                Text("Dikte")
                    .font(.dzHeading())
                    .foregroundColor(.dzTextPrimary)
                
                Spacer()
                
                Button(action: {
                    let delivered = NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    DikteLog.action("app", "settings.open.request", "Ayarlar penceresi açma isteği alındı.", metadata: [
                        "delivered": delivered,
                        "is_processing": appState.isProcessing,
                        "is_recording": appState.isRecording,
                        "show_result": appState.showResult
                    ])
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.dzTextMuted)
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "power")
                        .font(.system(size: 14))
                        .foregroundColor(.dzTextMuted)
                }
                .buttonStyle(.plain)
            }
            
            // Center Section: Status Ring
            statusRing
            
            // Bottom Section: Context Info or Toggle
            contextToggle
        }
        .padding(24)
        .frame(width: 320)
        // macOS MenuBarExtra window style will frame this, but we apply our custom glass background
        // Note: MenuBarExtra inherently has some background on macOS, but .window style allows custom backgrounds
        .glassPanel(radius: 18)
    }
    
    // MARK: - Status Ring
    
    private var statusRing: some View {
        Button(action: {
            if !appState.isProcessing {
                appState.toggleRecording()
            }
        }) {
            ZStack {
                // Background glow/ring
                Circle()
                    .fill(Color.dzSurfaceGlass)
                    .frame(width: 120, height: 120)
                    .shadow(color: appState.isRecording ? Color.dzPrimary.opacity(0.5) : .clear, radius: 20)
                
                if appState.isRecording {
                    // Fluid Blob for recording
                    FluidBlobView()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                    
                    Text(appState.formattedDuration)
                        .font(.dzHeading())
                        .foregroundColor(.dzTextPrimary)
                        .monospacedDigit()
                } else if appState.isProcessing {
                    ProgressView()
                        .controlSize(.regular)
                } else if appState.showResult {
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(.dzSuccess)
                } else {
                    // Idle
                    Image(systemName: "mic.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.dzTextMuted)
                }
            }
            .frame(height: 140) // Give it breathing room
        }
        .buttonStyle(SquishyButtonStyle())
    }
    
    // MARK: - Context Toggle
    
    private var contextToggle: some View {
        VStack(spacing: 8) {
            if appState.isRecording {
                Text("Kayıt devam ediyor...")
                    .font(.dzSmallText())
                    .foregroundColor(.dzTextMuted)
                
                Text("Panoya bir şeyler kopyalayın")
                    .font(.dzSmallText())
                    .foregroundColor(.dzTextMuted)
            } else if appState.isProcessing {
                Text("Yerel olarak işleniyor...")
                    .font(.dzSmallText())
                    .foregroundColor(.dzTextPrimary)
            } else if appState.showResult {
                Text("Panoya Kopyalandı")
                    .font(.dzButtonText())
                    .foregroundColor(.dzSuccess)
            } else {
                Text("Başlamak için dokun veya ⌘⇧Space")
                    .font(.dzSmallText())
                    .foregroundColor(.dzTextMuted)
            }
        }
        .frame(height: 40)
    }
}

// Custom button style for the squishy ring click
struct SquishyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    MenuBarView()
}
