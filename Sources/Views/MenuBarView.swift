import SwiftUI

/// Main popover content shown when the menu bar icon is clicked.
struct MenuBarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            Divider()

            // Content based on state
            if appState.isRecording {
                recordingSection
            } else if appState.isProcessing {
                processingSection
            } else if appState.showResult {
                resultSection
            } else {
                idleSection
            }

            Divider()

            // Footer
            footerSection
        }
        .frame(width: 380)
        .background(.ultraThinMaterial)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Image(systemName: "waveform.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)
            Text("Dikte")
                .font(.headline)

            Spacer()

            if appState.isRecording {
                Text(appState.formattedDuration)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.red)

                Circle()
                    .fill(.red)
                    .frame(width: 8, height: 8)
                    .modifier(PulseAnimation())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Idle State

    private var idleSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "mic.badge.plus")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)

            Text("Kaydı başlatmak için butona basın")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("veya ⌘⇧Space kısayolunu kullanın")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Button(action: { appState.toggleRecording() }) {
                Label("Kayda Başla", systemImage: "record.circle")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 24)
    }

    // MARK: - Recording State

    private var recordingSection: some View {
        VStack(spacing: 16) {
            // Waveform animation
            HStack(spacing: 3) {
                ForEach(0..<12, id: \.self) { index in
                    WaveformBar(index: index)
                }
            }
            .frame(height: 40)

            Text("Kayıt devam ediyor...")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Konuşurken metin, link veya görsel kopyalayabilirsiniz")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Button(action: { appState.toggleRecording() }) {
                Label("Kaydı Durdur", systemImage: "stop.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 24)
    }

    // MARK: - Processing State

    private var processingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text(appState.processingStatus)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 32)
    }

    // MARK: - Result State

    private var resultSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Çıktı hazır!")
                    .font(.subheadline.weight(.medium))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Scrollable result text
            ScrollView {
                Text(appState.mergedOutput)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }
            .frame(maxHeight: 200)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 12)

            // Action buttons
            HStack(spacing: 8) {
                Button(action: { appState.copyOutputToClipboard() }) {
                    Label("Panoya Kopyala", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .tint(.blue)

                Button(action: {
                    appState.showResult = false
                    appState.mergedOutput = ""
                }) {
                    Label("Temizle", systemImage: "xmark.circle")
                }
                .controlSize(.large)
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack {
            Button("Ayarlar...") {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundStyle(.secondary)

            Spacer()

            Button("Çıkış") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Waveform Bar Animation

struct WaveformBar: View {
    let index: Int

    @State private var height: CGFloat = 4

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(.red.gradient)
            .frame(width: 4, height: height)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 0.3...0.7))
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.05)
                ) {
                    height = CGFloat.random(in: 10...36)
                }
            }
    }
}

// MARK: - Pulse Animation Modifier

struct PulseAnimation: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 0.3 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}
