import SwiftUI

struct SplashView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var logoScale = 0.3
    @State private var logoOpacity = 0.0
    @State private var textOpacity = 0.0
    @State private var taglineOpacity = 0.0
    @State private var particleOpacity = 0.0

    var body: some View {
        ZStack {
            GoldRushTheme.Gradients.darkBackground
                .ignoresSafeArea()

            GoldDustParticleView(count: 40)
                .opacity(particleOpacity)
                .ignoresSafeArea()

            VStack(spacing: GoldRushTheme.Spacing.lg) {
                Spacer()
                logoSection
                titleSection
                Spacer()
                taglineText
            }
            .padding(GoldRushTheme.Spacing.xl)
        }
        .task { await runIntro() }
    }

    private var logoSection: some View {
        ZStack {
            Circle()
                .fill(GoldRushTheme.Colors.richGold.opacity(0.15))
                .frame(width: 140, height: 140)

            Circle()
                .strokeBorder(
                    GoldRushTheme.Gradients.goldShimmer,
                    lineWidth: 2
                )
                .frame(width: 140, height: 140)

            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(GoldRushTheme.Gradients.goldShimmer)
                .shimmer()
        }
        .scaleEffect(logoScale)
        .opacity(logoOpacity)
    }

    private var titleSection: some View {
        VStack(spacing: GoldRushTheme.Spacing.xs) {
            Text("GOLD RUSH")
                .font(GoldRushTheme.Typography.display(38))
                .foregroundStyle(GoldRushTheme.Gradients.goldShimmer)
                .tracking(6)
            Text("Quizzes & History")
                .font(GoldRushTheme.Typography.heading(18))
                .foregroundStyle(GoldRushTheme.Colors.parchment)
                .tracking(2)
        }
        .opacity(textOpacity)
    }

    private var taglineText: some View {
        Text("Discover the era that forged America")
            .font(GoldRushTheme.Typography.caption(14))
            .foregroundStyle(GoldRushTheme.Colors.ironGray)
            .opacity(taglineOpacity)
            .padding(.bottom, GoldRushTheme.Spacing.xxl)
    }

    private func runIntro() async {
        withAnimation(.spring(duration: 0.7, bounce: 0.4)) {
            logoScale   = 1.0
            logoOpacity = 1.0
        }
        try? await Task.sleep(for: .milliseconds(400))
        withAnimation(.easeOut(duration: 0.5)) {
            textOpacity = 1.0
        }
        try? await Task.sleep(for: .milliseconds(300))
        withAnimation(.easeOut(duration: 0.6)) {
            particleOpacity = 1.0
            taglineOpacity  = 1.0
        }
        try? await Task.sleep(for: .seconds(1.4))
        coordinator.completeSplash()
    }
}
