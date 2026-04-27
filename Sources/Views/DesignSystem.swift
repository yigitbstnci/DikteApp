import SwiftUI

// MARK: - Colors
extension Color {
    static let dzPrimary = Color(hex: "5E5CE6")
    static let dzGradientAccent = Color(hex: "32ADE6")
    static let dzBackgroundGlass = Color(red: 28/255, green: 28/255, blue: 30/255, opacity: 0.65)
    static let dzSurfaceGlass = Color(red: 44/255, green: 44/255, blue: 46/255, opacity: 0.5)
    static let dzTextPrimary = Color.white
    static let dzTextMuted = Color(hex: "EBEBF5").opacity(0.6)
    static let dzSuccess = Color(hex: "30D158")
    static let dzBorder = Color.white.opacity(0.1)
}

// MARK: - Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Modifiers
struct GlassmorphismModifier: ViewModifier {
    var radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Color.dzBackgroundGlass)
                    // macOS native blur
                    .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
                    .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Color.dzBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

extension View {
    func glassPanel(radius: CGFloat = 18) -> some View {
        self.modifier(GlassmorphismModifier(radius: radius))
    }
}

// Visual Effect View for SwiftUI macOS
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - Typography
extension Font {
    static func dzHeading() -> Font {
        .system(size: 20, weight: .semibold, design: .rounded)
    }
    
    static func dzBody() -> Font {
        .system(size: 14, weight: .regular, design: .rounded)
    }
    
    static func dzSmallText() -> Font {
        .system(size: 12, weight: .medium, design: .rounded)
    }
    
    static func dzButtonText() -> Font {
        .system(size: 13, weight: .medium) // SF Pro Text
    }
}
