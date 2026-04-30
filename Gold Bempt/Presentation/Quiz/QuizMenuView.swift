import SwiftUI

struct QuizMenuView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel: QuizMenuViewModel?
    @State private var showingQuiz = false
    @State private var activeSession: QuizSession?

    var body: some View {
        NavigationStack {
            ZStack {
                GoldRushTheme.Gradients.darkBackground
                    .ignoresSafeArea()

                if let vm = viewModel {
                    menuContent(vm: vm)
                } else {
                    ProgressView().tint(GoldRushTheme.Colors.richGold)
                }
            }
            .navigationTitle("Quiz Arena")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(GoldRushTheme.Colors.darkCharcoal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .fullScreenCover(item: $activeSession) { session in
            QuizView(session: session, coordinator: coordinator)
        }
        .task {
            viewModel = QuizMenuViewModel(quizUseCase: coordinator.quizUseCase)
        }
    }

    private func menuContent(vm: QuizMenuViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: GoldRushTheme.Spacing.lg) {
                modePicker(vm: vm)
                    .padding(.horizontal, GoldRushTheme.Spacing.md)

                if vm.selectedMode == .topicBased {
                    topicPicker(vm: vm)
                        .padding(.horizontal, GoldRushTheme.Spacing.md)
                }

                startButton(vm: vm)
                    .padding(.horizontal, GoldRushTheme.Spacing.md)
                    .padding(.bottom, GoldRushTheme.Spacing.xxl)
            }
            .padding(.top, GoldRushTheme.Spacing.lg)
        }
        .scrollIndicators(.hidden)
    }

    private func modePicker(vm: QuizMenuViewModel) -> some View {
        VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.sm) {
            SectionLabel(title: "SELECT MODE")

            ForEach(QuizMode.allCases) { mode in
                QuizModeCard(
                    mode: mode,
                    isSelected: vm.selectedMode == mode,
                    onSelect: { vm.selectedMode = mode }
                )
            }
        }
    }

    private func topicPicker(vm: QuizMenuViewModel) -> some View {
        VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.sm) {
            SectionLabel(title: "CHOOSE TOPIC")

            ScrollView(.horizontal) {
                HStack(spacing: GoldRushTheme.Spacing.xs) {
                    TopicChip(
                        title: "All Topics",
                        isSelected: vm.selectedTopic == nil,
                        onSelect: { vm.selectedTopic = nil }
                    )
                    ForEach(QuizTopic.allCases) { topic in
                        TopicChip(
                            title: topic.rawValue,
                            isSelected: vm.selectedTopic == topic,
                            onSelect: { vm.selectedTopic = topic }
                        )
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private func startButton(vm: QuizMenuViewModel) -> some View {
        GoldButton(title: "Start Quiz", action: {
            let session = coordinator.quizUseCase.startSession(
                mode: vm.selectedMode,
                topic: vm.selectedTopic
            )
            activeSession = session
        })
    }
}

// MARK: - Sub-views

private struct SectionLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(GoldRushTheme.Typography.caption(11))
            .foregroundStyle(GoldRushTheme.Colors.richGold)
            .tracking(2)
    }
}

private struct QuizModeCard: View {
    let mode: QuizMode
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: GoldRushTheme.Spacing.md) {
                Image(systemName: mode.iconName)
                    .font(.system(size: 26))
                    .foregroundStyle(isSelected
                                    ? GoldRushTheme.Colors.darkCharcoal
                                    : GoldRushTheme.Colors.richGold)
                    .frame(width: 44)

                VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.xxs) {
                    Text(mode.rawValue)
                        .font(GoldRushTheme.Typography.heading(17))
                        .foregroundStyle(isSelected
                                         ? GoldRushTheme.Colors.darkCharcoal
                                         : GoldRushTheme.Colors.parchment)
                    Text(mode.description)
                        .font(GoldRushTheme.Typography.caption(13))
                        .foregroundStyle(isSelected
                                         ? GoldRushTheme.Colors.deepBrown
                                         : GoldRushTheme.Colors.ironGray)
                        .lineLimit(2)
                }
            }
            .padding(GoldRushTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GoldRushTheme.Radius.md)
                    .fill(isSelected
                          ? AnyShapeStyle(GoldRushTheme.Gradients.goldShimmer)
                          : AnyShapeStyle(GoldRushTheme.Colors.deepBrown.opacity(0.6)))
            )
            .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.md))
            .overlay {
                RoundedRectangle(cornerRadius: GoldRushTheme.Radius.md)
                    .strokeBorder(
                        isSelected ? Color.clear : GoldRushTheme.Colors.richGold.opacity(0.25),
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.25), value: isSelected)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

private struct TopicChip: View {
    let title: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            Text(title)
                .font(GoldRushTheme.Typography.caption(13))
                .foregroundStyle(isSelected
                                 ? GoldRushTheme.Colors.darkCharcoal
                                 : GoldRushTheme.Colors.parchment)
                .padding(.vertical, GoldRushTheme.Spacing.xs)
                .padding(.horizontal, GoldRushTheme.Spacing.md)
                .background(isSelected
                             ? AnyShapeStyle(GoldRushTheme.Gradients.goldShimmer)
                             : AnyShapeStyle(GoldRushTheme.Colors.deepBrown.opacity(0.6)))
                .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.pill))
                .overlay {
                    Capsule().strokeBorder(
                        GoldRushTheme.Colors.richGold.opacity(isSelected ? 0 : 0.3),
                        lineWidth: 1
                    )
                }
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.2), value: isSelected)
    }
}

