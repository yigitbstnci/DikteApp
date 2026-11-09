import SwiftUI

struct FloatingHUDView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            if appState.isRecording {
                mainCard
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else if appState.isProcessing {
                mainCard
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else if appState.showResult {
                mainCard
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else if appState.processingError != nil {
                mainCard
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                modelReadyCard
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            if !appState.clipboardMonitor.items.isEmpty && (appState.isRecording || appState.isProcessing || appState.showResult) {
                clipboardStack
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
        .padding(.top, 20)
        .padding(.trailing, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .background(Color.clear)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.isRecording)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.isProcessing)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.showResult)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.processingError)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.clipboardMonitor.items.count)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.modelReadyState)
    }

    private var mainCard: some View {
        HStack(spacing: 12) {
            if appState.isRecording {
                FluidBlobView()
                    .frame(width: 24, height: 24)

                Text(appState.formattedDuration)
                    .font(.dzSmallText())
                    .foregroundColor(.dzTextPrimary)
                    .monospacedDigit()

                Spacer()

                Button(action: {
                    appState.stopRecording()
                }) {
                    Image(systemName: "stop.circle.fill")
                        .font(.title2)
                        .foregroundColor(.dzTextMuted)
                }
                .buttonStyle(.plain)
            } else if appState.isProcessing {
                ProgressView()
                    .controlSize(.small)

                if appState.processingStatus.contains("Ses metne") {
                    Text("✓ Saved ➝ Transcribing...")
                        .font(.dzSmallText())
                        .foregroundColor(.dzTextMuted)
                } else if appState.processingStatus.contains("Pano") {
                    Text("✓ Saved ➝ ✓ Transcribed ➝ Merging...")
                        .font(.dzSmallText())
                        .foregroundColor(.dzTextMuted)
                } else {
                    Text(appState.processingStatus)
                        .font(.dzSmallText())
                        .foregroundColor(.dzTextMuted)
                }

                Spacer()
            } else if appState.showResult {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.dzSuccess)
                Text("✓ Saved ➝ ✓ Transcribed ➝ ⌘V to paste")
                    .font(.dzSmallText())
                    .foregroundColor(.dzSuccess)
                Spacer()
            } else if let errorMessage = appState.processingError {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Kayıt işlenemedi")
                        .font(.dzSmallText())
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .foregroundColor(.dzTextMuted)
                        .lineLimit(1)
                }
                Spacer()
            }
        }
        .padding(12)
        .frame(width: 280)
        .glassPanel(radius: 12)
    }

    private var modelReadyCard: some View {
        HStack(spacing: 12) {
            switch appState.modelReadyState {
            case .preparing:
                ProgressView()
                    .controlSize(.small)
                Text("Model hazırlanıyor...")
                    .font(.dzSmallText())
                    .foregroundColor(.dzTextMuted)
            case .ready:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.dzSuccess)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Model Ready")
                        .font(.dzSmallText())
                        .foregroundColor(.dzSuccess)
                    if let shortcut = appState.recordingShortcut {
                        Text("Kayıt kısayolu: \(shortcut.description)")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.dzTextMuted)
                    }
                }
            case .failed(let message):
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Model hazırlanamadı")
                        .font(.dzSmallText())
                        .foregroundColor(.red)
                    Text(message)
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .foregroundColor(.dzTextMuted)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(12)
        .frame(width: 280)
        .glassPanel(radius: 12)
    }
    
    private var clipboardStack: some View {
        VStack(spacing: 8) {
            ForEach(appState.clipboardMonitor.items) { item in
                HStack(spacing: 8) {
                    Image(systemName: iconForApp(item.sourceApp))
                        .foregroundColor(.dzGradientAccent)
                        .font(.system(size: 14))
                    
                    Text(item.sourceApp ?? "Pano")
                        .font(.dzSmallText())
                        .foregroundColor(.dzTextPrimary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if item.type == .image {
                        Text(item.formattedFileSize)
                            .font(.system(size: 10, weight: .regular, design: .rounded))
                            .foregroundColor(.dzTextMuted)
                    } else if item.type == .url {
                        Text("URL")
                            .font(.system(size: 10, weight: .regular, design: .rounded))
                            .foregroundColor(.dzTextMuted)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(width: 280)
                .background(Color.dzSurfaceGlass)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.dzBorder, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .transition(.asymmetric(insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .bottom)), removal: .opacity))
            }
        }
    }
    
    private func iconForApp(_ appName: String?) -> String {
        guard let name = appName?.lowercased() else { return "doc.on.clipboard" }
        if name.contains("safari") || name.contains("chrome") || name.contains("arc") || name.contains("brave") {
            return "safari.fill"
        } else if name.contains("code") || name.contains("ghostty") || name.contains("xcode") || name.contains("terminal") {
            return "terminal.fill"
        } else if name.contains("notes") {
            return "note.text"
        } else if name.contains("finder") {
            return "folder.fill"
        }
        return "doc.on.clipboard"
    }
}
