import SwiftUI

struct QuizResultView: View {
    let session: QuizSession
    let coordinator: AppCoordinator

    @State private var scoreScale = 0.3
    @State private var contentOpacity = 0.0
    @State private var showConfetti = false
    @Environment(\.dismiss) private var dismiss

    private var accuracy: Double {
        guard !session.questions.isEmpty else { return 0 }
        return Double(session.correctCount) / Double(min(session.currentIndex, session.questions.count))
    }

    var body: some View {
        ZStack {
            GoldRushTheme.Gradients.darkBackground
                .ignoresSafeArea()

            if showConfetti {
                GoldDustParticleView(count: 60)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            ScrollView {
                VStack(spacing: GoldRushTheme.Spacing.xl) {
                    Spacer(minLength: GoldRushTheme.Spacing.xxl)
                    resultHero
                    statsGrid
                    actionButtons
                    Spacer(minLength: GoldRushTheme.Spacing.xxl)
                }
                .padding(.horizontal, GoldRushTheme.Spacing.lg)
            }
            .scrollIndicators(.hidden)
        }
        .task { await animateIn() }
    }

    private var resultHero: some View {
        VStack(spacing: GoldRushTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(GoldRushTheme.Colors.richGold.opacity(0.12))
                    .frame(width: 140, height: 140)
                Circle()
                    .strokeBorder(GoldRushTheme.Gradients.goldShimmer, lineWidth: 2)
                    .frame(width: 140, height: 140)
                VStack(spacing: 0) {
                    Text("\(session.correctCount)")
                        .font(GoldRushTheme.Typography.display(48))
                        .foregroundStyle(GoldRushTheme.Gradients.goldShimmer)
                    Text("/ \(min(session.currentIndex, session.questions.count))")
                        .font(GoldRushTheme.Typography.heading(18))
                        .foregroundStyle(GoldRushTheme.Colors.ironGray)
                }
            }
            .scaleEffect(scoreScale)
            .animation(.spring(duration: 0.7, bounce: 0.4), value: scoreScale)

            Text(resultTitle)
                .font(GoldRushTheme.Typography.display(28))
                .foregroundStyle(GoldRushTheme.Colors.parchment)
                .multilineTextAlignment(.center)

            Text("\(session.score) points earned")
                .font(GoldRushTheme.Typography.heading(18))
                .foregroundStyle(GoldRushTheme.Colors.richGold)
        }
        .opacity(contentOpacity)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: GoldRushTheme.Spacing.sm) {
            ResultStatCard(label: "Accuracy",      value: "\(Int(accuracy * 100))%")
            ResultStatCard(label: "Best Streak",   value: "\(session.streak)x")
            ResultStatCard(label: "Mode",          value: session.mode.rawValue)
            ResultStatCard(label: "Questions",     value: "\(min(session.currentIndex, session.questions.count))")
        }
        .opacity(contentOpacity)
    }

    private var actionButtons: some View {
        VStack(spacing: GoldRushTheme.Spacing.sm) {
            GoldButton(title: "Play Again", action: dismiss.callAsFunction)
            GoldButton(title: "Go Home", action: { coordinator.navigateTo(.home) }, style: .secondary)
        }
        .opacity(contentOpacity)
    }

    private var resultTitle: String {
        let pct = accuracy
        switch pct {
        case 0.9...:  return "Gold Strike!"
        case 0.7...:   return "Silver Seeker"
        case 0.5...:   return "Steady Miner"
        default:       return "Keep Digging"
        }
    }

    private func animateIn() async {
        try? await Task.sleep(for: .milliseconds(200))
        scoreScale = 1.0
        try? await Task.sleep(for: .milliseconds(300))
        withAnimation(.easeOut(duration: 0.5)) {
            contentOpacity = 1.0
        }
        if accuracy >= 0.9 {
            try? await Task.sleep(for: .milliseconds(200))
            showConfetti = true
        }
    }
}

private struct ResultStatCard: View {
    let label: String
    let value: String

    var body: some View {
        DarkCard {
            VStack(spacing: GoldRushTheme.Spacing.xxs) {
                Text(value)
                    .font(GoldRushTheme.Typography.heading(22))
                    .foregroundStyle(GoldRushTheme.Colors.parchment)
                Text(label)
                    .font(GoldRushTheme.Typography.caption(11))
                    .foregroundStyle(GoldRushTheme.Colors.ironGray)
            }
            .frame(maxWidth: .infinity)
            .padding(GoldRushTheme.Spacing.md)
        }
    }
}
