import SwiftUI

struct ProgressRing: View {
    let value: Double
    let total: Double
    var lineWidth: Double = 8
    var color: Color = GoldRushTheme.Colors.richGold

    private var fraction: Double {
        guard total > 0 else { return 0 }
        return min(max(value / total, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(
                    AngularGradient(
                        colors: [color, GoldRushTheme.Colors.brightGold],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(duration: 0.6), value: fraction)
        }
    }
}
