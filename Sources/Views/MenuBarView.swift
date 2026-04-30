import SwiftUI
import AppKit

/// SwiftUI panel shown when the menu bar icon is clicked.
struct MenuBarView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedSection: PanelSection = .recording

    var body: some View {
        VStack(spacing: 0) {
            header

            Picker("", selection: $selectedSection) {
                ForEach(PanelSection.allCases) { section in
                    Label(section.title, systemImage: section.systemImage)
                        .tag(section)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, 14)
            .padding(.bottom, 12)

            Divider()

            Group {
                switch selectedSection {
                case .recording:
                    recordingPanel
                case .clipboard:
                    clipboardPanel
                case .settings:
                    SettingsView()
                        .environment(appState)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 300, alignment: .top)

            Divider()

            footer
        }
        .frame(width: 380)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: appState.isRecording ? "record.circle.fill" : "mic.badge.plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(appState.isRecording ? .red : .dzPrimary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Dikte")
                    .font(.dzHeading())
                Text(statusText)
                    .font(.dzSmallText())
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
    }

    private var recordingPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            statusCard

            Button(action: appState.toggleRecording) {
                Label(recordingActionTitle, systemImage: recordingActionIcon)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(appState.isProcessing)

            if let processingError = appState.processingError {
                Label(processingError, systemImage: "exclamationmark.triangle")
                    .font(.dzSmallText())
                    .foregroundStyle(.red)
            }

            modelStateRow

            Spacer(minLength: 0)
        }
        .padding(16)
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(statusText)
                    .font(.dzBody())
                    .fontWeight(.semibold)
                Spacer()
                Text(appState.formattedDuration)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(appState.isRecording ? .red : .secondary)
            }

            if appState.isProcessing {
                ProgressView()
                Text(appState.processingStatus.isEmpty ? "Yerel olarak işleniyor..." : appState.processingStatus)
                    .font(.dzSmallText())
                    .foregroundStyle(.secondary)
            } else if appState.isRecording {
                Text("Pano takip ediliyor. Bitirdiğinde kayıt durdurulacak ve sonuç panoya yazılacak.")
                    .font(.dzSmallText())
                    .foregroundStyle(.secondary)
            } else {
                Text("Kısayolu Ayarlar sekmesinden değiştirebilirsin.")
                    .font(.dzSmallText())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var modelStateRow: some View {
        HStack(spacing: 10) {
            switch appState.modelReadyState {
            case .preparing:
                ProgressView()
                    .controlSize(.small)
                Text("Model hazırlanıyor")
            case .ready:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Model hazır")
            case .failed:
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
                Text("Model hazırlanamadı")
            }

            Spacer()
            Text(appState.settings.selectedModel.displayName)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .font(.dzSmallText())
    }

    private var clipboardPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(appState.isRecording ? "Pano takibi aktif" : "Pano takibi pasif", systemImage: appState.isRecording ? "checkmark.circle" : "pause.circle")
                Spacer()
                if let currentSession = appState.currentSession {
                    Text("Son: \(currentSession.clipboardItems.count) öğe")
                        .foregroundStyle(.secondary)
                }
            }
            .font(.dzBody())

            let items = appState.isRecording ? appState.clipboardMonitor.items : (appState.currentSession?.clipboardItems ?? [])

            if items.isEmpty {
                ContentUnavailableView(
                    "Pano öğesi yok",
                    systemImage: "doc.on.clipboard",
                    description: Text("Kayıt sırasında kopyaladığın metin, link veya görseller burada özetlenir.")
                )
                .frame(maxWidth: .infinity, minHeight: 180)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(items.prefix(8))) { item in
                            clipboardRow(item)
                        }
                    }
                }
                .frame(maxHeight: 240)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
    }

    private func clipboardRow(_ item: ClipboardItem) -> some View {
        HStack(spacing: 10) {
            Image(systemName: clipboardIcon(for: item))
                .foregroundStyle(Color.dzPrimary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.sourceApp ?? "Pano")
                    .font(.dzSmallText())
                Text(clipboardDescription(for: item))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var footer: some View {
        HStack {
            Text(appState.settings.selectedLanguage.displayName)
                .font(.dzSmallText())
                .foregroundStyle(.secondary)
            Spacer()
            Button("Çıkış", action: quit)
                .keyboardShortcut("q")
        }
        .padding(14)
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

    private var recordingActionTitle: String {
        appState.isRecording ? "Kaydı Durdur" : "Kayıt Başlat"
    }

    private var recordingActionIcon: String {
        appState.isRecording ? "stop.circle" : "mic.circle"
    }

    private func clipboardIcon(for item: ClipboardItem) -> String {
        switch item.type {
        case .image: return "photo"
        case .url: return "link"
        case .text: return "text.alignleft"
        }
    }

    private func clipboardDescription(for item: ClipboardItem) -> String {
        switch item.type {
        case .image:
            return "Görsel · \(item.formattedFileSize)"
        case .url:
            return "URL · \(item.formattedFileSize)"
        case .text:
            return "Metin · \(item.formattedFileSize)"
        }
    }

    private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

private enum PanelSection: String, CaseIterable, Identifiable {
    case recording
    case clipboard
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .recording: return "Kayıt"
        case .clipboard: return "Pano"
        case .settings: return "Ayarlar"
        }
    }

    var systemImage: String {
        switch self {
        case .recording: return "waveform"
        case .clipboard: return "doc.on.clipboard"
        case .settings: return "gearshape"
        }
    }
}
