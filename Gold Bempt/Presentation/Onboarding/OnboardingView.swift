import SwiftUI

struct OnboardingView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            GoldRushTheme.Gradients.darkBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                skipButton
                    .padding(.horizontal, GoldRushTheme.Spacing.lg)

                TabView(selection: $viewModel.currentPage) {
                    ForEach(viewModel.slides) { slide in
                        OnboardingSlideView(slide: slide)
                            .tag(slide.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: viewModel.currentPage)

                pageIndicator
                    .padding(.top, GoldRushTheme.Spacing.lg)

                bottomControls
                    .padding(GoldRushTheme.Spacing.xl)
            }
        }
    }

    private var skipButton: some View {
        HStack {
            Spacer()
            if !viewModel.isLastSlide {
                Button("Skip", action: viewModel.skip)
                    .font(GoldRushTheme.Typography.caption())
                    .foregroundStyle(GoldRushTheme.Colors.ironGray)
                    .padding(.top, GoldRushTheme.Spacing.md)
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: GoldRushTheme.Spacing.xs) {
            ForEach(viewModel.slides.indices, id: \.self) { index in
                Capsule()
                    .fill(index == viewModel.currentPage
                          ? GoldRushTheme.Colors.richGold
                          : GoldRushTheme.Colors.ironGray.opacity(0.4))
                    .frame(width: index == viewModel.currentPage ? 24 : 8, height: 8)
                    .animation(.spring(duration: 0.3), value: viewModel.currentPage)
            }
        }
    }

    private var bottomControls: some View {
        GoldButton(
            title: viewModel.isLastSlide ? "Start Exploring" : "Continue",
            action: handlePrimaryAction
        )
    }

    private func handlePrimaryAction() {
        if viewModel.isLastSlide {
            coordinator.completeOnboarding()
        } else {
            viewModel.advance()
        }
    }
}

// MARK: - Slide View

private struct OnboardingSlideView: View {
    let slide: OnboardingSlide
    @State private var iconScale = 0.5
    @State private var contentOpacity = 0.0
    @State private var iconOffset = 30.0

    var body: some View {
        VStack(spacing: GoldRushTheme.Spacing.xl) {
            Spacer()

            iconArea
                .scaleEffect(iconScale)
                .offset(y: iconOffset)

            contentArea
                .opacity(contentOpacity)

            Spacer()
        }
        .padding(.horizontal, GoldRushTheme.Spacing.xl)
        .onAppear(perform: animateIn)
    }

    private var iconArea: some View {
        ZStack {
            Circle()
                .fill(GoldRushTheme.Colors.richGold.opacity(0.12))
                .frame(width: 160, height: 160)

            Circle()
                .strokeBorder(GoldRushTheme.Colors.richGold.opacity(0.3), lineWidth: 1.5)
                .frame(width: 160, height: 160)

            Image(systemName: slide.iconName)
                .font(.system(size: 68))
                .foregroundStyle(GoldRushTheme.Gradients.goldShimmer)
        }
    }

    private var contentArea: some View {
        VStack(spacing: GoldRushTheme.Spacing.md) {
            Text(slide.title)
                .font(GoldRushTheme.Typography.display(32))
                .foregroundStyle(GoldRushTheme.Colors.parchment)
                .multilineTextAlignment(.center)

            Text(slide.subtitle)
                .font(GoldRushTheme.Typography.heading(16))
                .foregroundStyle(GoldRushTheme.Colors.richGold)
                .multilineTextAlignment(.center)

            Text(slide.body)
                .font(GoldRushTheme.Typography.body(15))
                .foregroundStyle(GoldRushTheme.Colors.parchmentDark)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
        }
    }

    private func animateIn() {
        withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
            iconScale  = 1.0
            iconOffset = 0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            contentOpacity = 1.0
        }
    }
}
