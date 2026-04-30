import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase = 0.0
    var active = true

    func body(content: Content) -> some View {
        content
            .overlay {
                if active {
                    LinearGradient(
                        colors: [
                            .clear,
                            GoldRushTheme.Colors.brightGold.opacity(0.35),
                            .clear,
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .offset(x: phase == 0 ? -300 : 300)
                    .animation(
                        .linear(duration: 1.8).repeatForever(autoreverses: false),
                        value: phase
                    )
                }
            }
            .clipShape(.rect)
            .task {
                guard active else { return }
                phase = 1
            }
    }
}

extension View {
    func shimmer(active: Bool = true) -> some View {
        modifier(ShimmerModifier(active: active))
    }
}
