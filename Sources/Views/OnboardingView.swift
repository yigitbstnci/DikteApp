import SwiftUI

struct OnboardingView: View {
    @Binding var modelReadyState: AppState.ModelReadyState

    private var progress: Double {
        switch modelReadyState {
        case .preparing:
            return 0.45
        case .ready:
            return 1.0
        case .failed:
            return 1.0
        }
    }

    private var isComplete: Bool {
        switch modelReadyState {
        case .preparing:
            return false
        case .ready, .failed:
            return true
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(.dzPrimary)
                .shadow(color: Color.dzPrimary.opacity(0.6), radius: 15)
                .padding(.bottom, 8)

            Text("Yerel Yapay Zeka Hazırlanıyor")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.dzTextPrimary)

            VStack(spacing: 12) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(colors: [.dzPrimary, .dzGradientAccent], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * progress, height: 8)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                    }
                }
                .frame(height: 8)

                Text(statusText)
                    .font(.dzSmallText())
                    .foregroundColor(.dzTextMuted)
            }
            .padding(.horizontal, 40)

            if isComplete {
                Button(action: {
                    // Close onboarding / finish setup
                }) {
                    Text("Dikte'ye Başla")
                        .font(.dzButtonText())
                        .frame(width: 140)
                }
                .buttonStyle(.borderedProminent)
                .tint(.dzPrimary)
                .controlSize(.large)
                .transition(.opacity.combined(with: .scale))
            } else {
                Button("Hidden") {}
                    .controlSize(.large)
                    .opacity(0)
            }
        }
        .padding(32)
        .frame(width: 480, height: 320)
    }

    private var statusText: String {
        switch modelReadyState {
        case .preparing:
            return "İndiriliyor: Whisper-Large-Turbo (420 MB / 954 MB)"
        case .ready:
            return "Model başarıyla yüklendi."
        case .failed(let message):
            return "Model hazırlanamadı: \(message)"
        }
    }
}

#Preview("Preparing") {
    OnboardingView(modelReadyState: .constant(.preparing))
        .glassPanel()
        .padding()
        .background(Color.black.opacity(0.8))
}

#Preview("Ready") {
    OnboardingView(modelReadyState: .constant(.ready))
        .glassPanel()
        .padding()
        .background(Color.black.opacity(0.8))
}

#Preview("Failed") {
    OnboardingView(modelReadyState: .constant(.failed("Disk dolu")))
        .glassPanel()
        .padding()
        .background(Color.black.opacity(0.8))
}
