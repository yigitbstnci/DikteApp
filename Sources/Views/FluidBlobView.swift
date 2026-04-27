import SwiftUI

struct FluidBlobView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate * 1.5
            
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    .init(0, 0), .init(0.5, 0), .init(1, 0),
                    .init(0, 0.5),
                    .init(Float(0.5 + 0.15 * sin(t)), Float(0.5 + 0.15 * cos(t * 0.8))),
                    .init(1, 0.5),
                    .init(0, 1), .init(0.5, 1), .init(1, 1)
                ],
                colors: [
                    Color.dzPrimary, Color.dzGradientAccent, Color.dzPrimary,
                    Color.dzGradientAccent, Color.dzPrimary, Color.dzGradientAccent,
                    Color.dzPrimary, Color.dzGradientAccent, Color.dzPrimary
                ]
            )
            .clipShape(Circle())
        }
    }
}

#Preview {
    FluidBlobView()
        .frame(width: 150, height: 150)
        .padding()
        .background(Color.black)
}
