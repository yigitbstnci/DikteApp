import SwiftUI

struct OnboardingView: View {
    // This would typically be driven by AppState/TranscriptionService progress
    @State private var progress: Double = 0.45
    @State private var isComplete = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(.dzPrimary)
                // Subtle glow effect
                .shadow(color: Color.dzPrimary.opacity(0.6), radius: 15)
                .padding(.bottom, 8)
            
            Text("Yerel Yapay Zeka Hazırlanıyor")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.dzTextPrimary)
            
            VStack(spacing: 12) {
                // Custom progress bar to match PRD
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
                
                Text(isComplete ? "Model başarıyla yüklendi." : "İndiriliyor: Whisper-Large-Turbo (420 MB / 954 MB)")
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
                // Invisible placeholder to keep height stable
                Button("Hidden") {}
                    .controlSize(.large)
                    .opacity(0)
            }
        }
        .padding(32)
        .frame(width: 480, height: 320)
        // Simulated completion for preview
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                progress = 1.0
                withAnimation(.easeIn(duration: 0.3).delay(0.5)) {
                    isComplete = true
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        // Wrapped in glass panel for preview
        .glassPanel()
        .padding()
        .background(Color.black.opacity(0.8))
}
