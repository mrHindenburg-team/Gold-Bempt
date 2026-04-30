import SwiftUI

struct ParchmentCard<Content: View>: View {
    @ViewBuilder let content: Content
    var cornerRadius: Double = GoldRushTheme.Radius.lg

    var body: some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(GoldRushTheme.Gradients.parchmentBackground)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            GoldRushTheme.Colors.richGold.opacity(0.4),
                            lineWidth: 1
                        )
                }
            )
            .clipShape(.rect(cornerRadius: cornerRadius))
            .shadow(color: GoldRushTheme.Colors.deepBrown.opacity(0.35), radius: 10, x: 0, y: 5)
    }
}

struct DarkCard<Content: View>: View {
    @ViewBuilder let content: Content
    var cornerRadius: Double = GoldRushTheme.Radius.lg

    var body: some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(GoldRushTheme.Gradients.cardDepth)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            GoldRushTheme.Colors.richGold.opacity(0.25),
                            lineWidth: 1
                        )
                }
            )
            .clipShape(.rect(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
    }
}
