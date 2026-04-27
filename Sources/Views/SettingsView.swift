import SwiftUI
import KeyboardShortcuts

/// Settings window following macOS preferences design.
struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var selection: String? = "general"

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                NavigationLink(value: "general") {
                    Label("Genel", systemImage: "gearshape")
                        .font(.dzButtonText())
                }
                NavigationLink(value: "language") {
                    Label("Dil & Model", systemImage: "cpu")
                        .font(.dzButtonText())
                }
                NavigationLink(value: "output") {
                    Label("Çıktı", systemImage: "doc.text")
                        .font(.dzButtonText())
                }
            }
            .navigationSplitViewColumnWidth(160)
            .listStyle(.sidebar)
        } detail: {
            Group {
                switch selection {
                case "general":
                    generalTab
                case "language":
                    languageTab
                case "output":
                    outputTab
                default:
                    Text("Bir ayar kategorisi seçin")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(width: 600, height: 400)
    }

    // MARK: - Tabs

    private var generalTab: some View {
        Form {
            Section {
                HStack {
                    Text("Kayıt Kısayolu:")
                        .font(.dzButtonText())
                    Spacer()
                    KeyboardShortcuts.Recorder("", name: .toggleRecording)
                }
                
                Toggle("Başlangıçta Çalıştır", isOn: .constant(true))
                    .font(.dzButtonText())
                    .toggleStyle(.switch)
            } header: {
                Text("Kısayollar ve Sistem")
            } footer: {
                Text("Bu kısayol ile herhangi bir uygulamadayken kaydı başlatıp durdurabilirsiniz.")
                    .font(.dzSmallText())
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private var languageTab: some View {
        Form {
            Section {
                Picker("Dikte Dili", selection: .constant("tr")) {
                    Text("Türkçe").tag("tr")
                    Text("İngilizce").tag("en")
                }
                .font(.dzButtonText())
                
                Picker("Yapay Zeka Modeli", selection: .constant("large-v3-turbo")) {
                    Text("Whisper Large v3 Turbo").tag("large-v3-turbo")
                    Text("Whisper Base").tag("base")
                }
                .font(.dzButtonText())
            } header: {
                Text("Dil ve Tanıma Ayarları")
            } footer: {
                Text("Large v3 Turbo modeli Türkçe için en iyi sonucu verir ancak diskte yaklaşık 1GB yer kaplar.")
                    .font(.dzSmallText())
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private var outputTab: some View {
        Form {
            Section {
                Toggle("Ekleri dipnot (¹, ²) olarak ekle", isOn: .constant(true))
                    .font(.dzButtonText())
                    .toggleStyle(.switch)
                Toggle("Panoya otomatik kopyala", isOn: .constant(true))
                    .font(.dzButtonText())
                    .toggleStyle(.switch)
            } header: {
                Text("Markdown ve Pano")
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    SettingsView()
}
