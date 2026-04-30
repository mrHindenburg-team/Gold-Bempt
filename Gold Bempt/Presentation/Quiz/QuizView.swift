import SwiftUI

struct QuizView: View {
    @State private var viewModel: QuizViewModel
    @State private var showQuitConfirm = false
    @Environment(\.dismiss) private var dismiss
    private let coordinator: AppCoordinator

    init(session: QuizSession, coordinator: AppCoordinator) {
        self._viewModel = State(
            initialValue: QuizViewModel(
                session: session,
                progressUseCase: coordinator.progressUseCase
            )
        )
        self.coordinator = coordinator
    }

    var body: some View {
        ZStack {
            backgroundGradient
            if viewModel.isFinished {
                QuizResultView(session: viewModel.session, coordinator: coordinator)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
            } else {
                quizContent
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.isFinished)
        .confirmationDialog("Quit Quiz?", isPresented: $showQuitConfirm, titleVisibility: .visible) {
            Button("Quit", role: .destructive) { dismiss() }
            Button("Keep Playing", role: .cancel) {}
        } message: {
            Text("Your current progress will not be saved.")
        }
    }

    private var backgroundGradient: some View {
        Group {
            if viewModel.session.mode == .survival {
                GoldRushTheme.Gradients.survivalRed
            } else {
                GoldRushTheme.Gradients.darkBackground
            }
        }
        .ignoresSafeArea()
    }

    private var quizContent: some View {
        VStack(spacing: 0) {
            QuizHeaderBar(
                index: viewModel.currentIndex,
                total: viewModel.totalCount,
                score: viewModel.score,
                streak: viewModel.streak,
                progress: viewModel.progress,
                isTimed: viewModel.session.mode.isTimed,
                timeProgress: viewModel.timerProgress,
                onQuit: { showQuitConfirm = true }
            )

            if let question = viewModel.currentQuestion {
                QuizQuestionCard(
                    question: question,
                    selectedIndex: viewModel.selectedAnswerIndex,
                    answerState: viewModel.answerState,
                    showExplanation: viewModel.showExplanation,
                    onSelect: viewModel.select,
                    onRevealExplanation: viewModel.revealExplanation,
                    onContinue: viewModel.advance
                )
                .padding(GoldRushTheme.Spacing.md)
            }

            Spacer()
        }
    }
}

// MARK: - Header Bar

private struct QuizHeaderBar: View {
    let index: Int
    let total: Int
    let score: Int
    let streak: Int
    let progress: Double
    let isTimed: Bool
    let timeProgress: Double
    let onQuit: () -> Void

    @State private var popupDelta: Int = 0
    @State private var popupOpacity: Double = 0
    @State private var popupOffset: CGFloat = 0
    @State private var scoreScale: Double = 1.0

    var body: some View {
        VStack(spacing: GoldRushTheme.Spacing.xs) {
            HStack {
                Button("Quit", systemImage: "xmark") { onQuit() }
                    .labelStyle(.iconOnly)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(GoldRushTheme.Colors.ironGray)
                    .frame(width: 36, height: 36)
                    .background(GoldRushTheme.Colors.deepBrown.opacity(0.6))
                    .clipShape(.circle)

                Text("Q\(index + 1) of \(total == .max ? "∞" : "\(total)")")
                    .font(GoldRushTheme.Typography.caption())
                    .foregroundStyle(GoldRushTheme.Colors.ironGray)
                    .frame(maxWidth: .infinity)

                if streak > 1 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(GoldRushTheme.Colors.mutedOrange)
                        Text("\(streak)")
                            .font(GoldRushTheme.Typography.caption())
                            .foregroundStyle(GoldRushTheme.Colors.mutedOrange)
                    }
                }
                ZStack(alignment: .top) {
                    Text("\(score) pts")
                        .font(GoldRushTheme.Typography.heading(16))
                        .foregroundStyle(GoldRushTheme.Colors.richGold)
                        .scaleEffect(scoreScale)
                    if popupOpacity > 0 {
                        Text("+\(popupDelta)")
                            .font(GoldRushTheme.Typography.caption(12))
                            .foregroundStyle(GoldRushTheme.Colors.mossGreen)
                            .offset(y: popupOffset - 16)
                            .opacity(popupOpacity)
                    }
                }
                .onChange(of: score) { oldValue, newValue in
                    guard newValue > oldValue else { return }
                    popupDelta = newValue - oldValue
                    popupOffset = 0
                    popupOpacity = 1.0
                    withAnimation(.easeOut(duration: 0.6)) {
                        popupOffset = -20
                        popupOpacity = 0.0
                    }
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                        scoreScale = 1.2
                    }
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6).delay(0.15)) {
                        scoreScale = 1.0
                    }
                }
            }
            .padding(.horizontal, GoldRushTheme.Spacing.md)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(GoldRushTheme.Colors.deepBrown)
                        .frame(height: 4)
                    Capsule()
                        .fill(isTimed
                              ? Color(red: timeProgress, green: timeProgress * 0.6, blue: 0)
                              : GoldRushTheme.Colors.richGold)
                        .frame(width: geo.size.width * (isTimed ? timeProgress : progress), height: 4)
                        .animation(.linear(duration: 0.1), value: isTimed ? timeProgress : progress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, GoldRushTheme.Spacing.md)
        }
        .padding(.vertical, GoldRushTheme.Spacing.md)
    }
}

// MARK: - Question Card

private struct QuizQuestionCard: View {
    let question: Question
    let selectedIndex: Int?
    let answerState: QuizViewModel.AnswerState
    let showExplanation: Bool
    let onSelect: (Int) -> Void
    let onRevealExplanation: () -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: GoldRushTheme.Spacing.md) {
            ParchmentCard {
                Text(question.text)
                    .font(GoldRushTheme.Typography.heading(18))
                    .foregroundStyle(GoldRushTheme.Colors.deepBrown)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                    .padding(GoldRushTheme.Spacing.md)
            }

            VStack(spacing: GoldRushTheme.Spacing.sm) {
                ForEach(question.options.indices, id: \.self) { idx in
                    AnswerButton(
                        text: question.options[idx],
                        index: idx,
                        selectedIndex: selectedIndex,
                        answerState: answerState,
                        onSelect: onSelect
                    )
                }
            }

            if case .correct = answerState {
                feedbackRow(correct: true)
            } else if case .incorrect = answerState {
                feedbackRow(correct: false)
            }
        }
    }

    private func feedbackRow(correct: Bool) -> some View {
        VStack(spacing: GoldRushTheme.Spacing.sm) {
            DarkCard {
                HStack(spacing: GoldRushTheme.Spacing.xs) {
                    Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(correct ? GoldRushTheme.Colors.mossGreen : GoldRushTheme.Colors.crimsonRed)
                        .font(.system(size: 22))
                    Text(correct ? "Correct!" : "Not quite.")
                        .font(GoldRushTheme.Typography.heading(16))
                        .foregroundStyle(GoldRushTheme.Colors.parchment)
                    Spacer()
                    if !showExplanation {
                        Button("Why?", action: onRevealExplanation)
                            .font(GoldRushTheme.Typography.caption())
                            .foregroundStyle(GoldRushTheme.Colors.richGold)
                    }
                }
                .padding(GoldRushTheme.Spacing.sm)
            }

            if showExplanation {
                ParchmentCard {
                    Text(question.explanation)
                        .font(GoldRushTheme.Typography.body(14))
                        .foregroundStyle(GoldRushTheme.Colors.deepBrown)
                        .lineSpacing(4)
                        .padding(GoldRushTheme.Spacing.sm)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            GoldButton(title: "Continue", action: onContinue)
        }
        .animation(.easeInOut(duration: 0.3), value: showExplanation)
    }
}

// MARK: - Answer Button

private struct AnswerButton: View {
    let text: String
    let index: Int
    let selectedIndex: Int?
    let answerState: QuizViewModel.AnswerState
    let onSelect: (Int) -> Void

    @State private var shakeCount: CGFloat = 0
    @State private var bounceScale: CGFloat = 1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isSelected: Bool { selectedIndex == index }

    private var fillColor: Color {
        switch answerState {
        case .unanswered:
            return isSelected ? GoldRushTheme.Colors.richGold.opacity(0.15) : GoldRushTheme.Colors.deepBrown.opacity(0.5)
        case .correct:
            return isSelected ? GoldRushTheme.Colors.mossGreen.opacity(0.3) : GoldRushTheme.Colors.deepBrown.opacity(0.5)
        case .incorrect(let correct):
            if isSelected { return GoldRushTheme.Colors.crimsonRed.opacity(0.3) }
            if index == correct { return GoldRushTheme.Colors.mossGreen.opacity(0.3) }
            return GoldRushTheme.Colors.deepBrown.opacity(0.5)
        }
    }

    private var strokeColor: Color {
        switch answerState {
        case .unanswered:
            return isSelected ? GoldRushTheme.Colors.richGold : GoldRushTheme.Colors.richGold.opacity(0.2)
        case .correct:
            return isSelected ? GoldRushTheme.Colors.mossGreen : GoldRushTheme.Colors.richGold.opacity(0.2)
        case .incorrect(let correct):
            if isSelected { return GoldRushTheme.Colors.crimsonRed }
            if index == correct { return GoldRushTheme.Colors.mossGreen }
            return GoldRushTheme.Colors.richGold.opacity(0.2)
        }
    }

    var body: some View {
        Button(action: { onSelect(index) }) {
            HStack(spacing: GoldRushTheme.Spacing.sm) {
                Text(optionLabel)
                    .font(GoldRushTheme.Typography.heading(15))
                    .foregroundStyle(GoldRushTheme.Colors.richGold)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(GoldRushTheme.Colors.richGold.opacity(0.15)))

                Text(text)
                    .font(GoldRushTheme.Typography.body(15))
                    .foregroundStyle(GoldRushTheme.Colors.parchment)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)

                Spacer()
            }
            .padding(GoldRushTheme.Spacing.md)
            .background(RoundedRectangle(cornerRadius: GoldRushTheme.Radius.md).fill(fillColor))
            .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.md))
            .overlay {
                RoundedRectangle(cornerRadius: GoldRushTheme.Radius.md)
                    .strokeBorder(strokeColor, lineWidth: 1.5)
            }
            .animation(.spring(duration: 0.25), value: answerState == .unanswered)
        }
        .scaleEffect(bounceScale)
        .modifier(ShakeEffect(shakes: shakeCount))
        .disabled(answerState != .unanswered)
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .medium), trigger: isSelected)
        .onChange(of: answerState) { _, newState in
            guard isSelected else { return }
            if case .correct = newState {
                guard !reduceMotion else { return }
                withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) {
                    bounceScale = 1.08
                }
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6).delay(0.15)) {
                    bounceScale = 1.0
                }
            } else if case .incorrect = newState {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 0.4)) {
                    shakeCount += 1
                }
            }
        }
    }

    private var optionLabel: String {
        ["A", "B", "C", "D"][safe: index] ?? "\(index + 1)"
    }
}

private struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: sin(shakes * .pi * 4) * 10, y: 0))
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
