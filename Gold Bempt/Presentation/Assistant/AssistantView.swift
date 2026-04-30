import SwiftUI

struct AssistantView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel: AssistantViewModel?
    @FocusState private var focus

    var body: some View {
        NavigationStack {
            ZStack {
                GoldRushTheme.Gradients.darkBackground
                    .ignoresSafeArea()

                if let vm = viewModel {
                    assistantContent(vm: vm)
                } else {
                    ProgressView().tint(GoldRushTheme.Colors.richGold)
                }
            }
            .navigationTitle("AI Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(GoldRushTheme.Colors.darkCharcoal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onTapGesture {
                focus = false
            }
        }
        .task {
            let vm = AssistantViewModel(
                assistantUseCase: coordinator.assistantUseCase,
                speechService:    coordinator.speechService,
                storeKit:         coordinator.storeKit
            )
            await vm.requestSpeechPermission()
            viewModel = vm
        }
    }

    private func assistantContent(vm: AssistantViewModel) -> some View {
        VStack(spacing: 0) {
            if vm.messages.isEmpty {
                AssistantWelcomeView(onSelect: { vm.inputText = $0 })
            } else {
                messageList(vm: vm)
            }

            if vm.isAtFreeLimit {
                FreeLimitBanner(onUpgrade: { coordinator.navigateTo(.profile) })
            }

            inputBar(vm: vm)
        }
    }

    private func messageList(vm: AssistantViewModel) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: GoldRushTheme.Spacing.sm) {
                    ForEach(vm.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    if vm.isThinking {
                        ThinkingBubble()
                            .id("thinking")
                    }
                    if !vm.messages.isEmpty {
                        ClearHistoryButton(onClear: vm.clearHistory)
                            .id("clearButton")
                    }
                }
                .padding(.horizontal, GoldRushTheme.Spacing.md)
                .padding(.vertical, GoldRushTheme.Spacing.md)
            }
            .scrollIndicators(.hidden)
            .onChange(of: vm.messages.count) {
                withAnimation {
                    if let lastID = vm.messages.last?.id {
                        proxy.scrollTo(lastID, anchor: .bottom)
                    }
                }
            }
            .onChange(of: vm.isThinking) {
                if vm.isThinking {
                    withAnimation { proxy.scrollTo("thinking", anchor: .bottom) }
                }
            }
        }
    }

    private func inputBar(vm: AssistantViewModel) -> some View {
        @Bindable var vm = vm
        return HStack(spacing: GoldRushTheme.Spacing.xs) {
            TextField("", text: $vm.inputText, axis: .vertical)
                .font(GoldRushTheme.Typography.body(15))
                .foregroundStyle(.white)
                .lineLimit(1...4)
                .padding(GoldRushTheme.Spacing.sm)
                .background(GoldRushTheme.Colors.deepBrown.opacity(0.8))
                .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.md))
                .overlay {
                    RoundedRectangle(cornerRadius: GoldRushTheme.Radius.md)
                        .strokeBorder(GoldRushTheme.Colors.richGold.opacity(0.3), lineWidth: 1)
                }
                .focused($focus)
                .onChange(of: coordinator.speechService.state) { _, new in
                    vm.handleSpeechState(new)
                }

            VoiceButton(
                isActive: vm.isVoiceActive,
                isAuthorized: coordinator.speechService.isAuthorized,
                onToggle: vm.toggleVoice
            )

            SendButton(
                isEnabled: !vm.inputText.trimmingCharacters(in: .whitespaces).isEmpty && !vm.isThinking,
                onSend: {
                    Task { await vm.sendMessage() }
                }
            )
        }
        .padding(.horizontal, GoldRushTheme.Spacing.md)
        .padding(.vertical, GoldRushTheme.Spacing.sm)
        .background(GoldRushTheme.Colors.darkCharcoal.opacity(0.95))
    }
}

// MARK: - Animated Welcome

private struct AssistantWelcomeView: View {
    let onSelect: (String) -> Void

    @State private var orbPulse = false
    @State private var ringScale: [CGFloat] = [1, 1, 1]
    @State private var ringOpacity: [Double] = [0.5, 0.35, 0.2]
    @State private var titleOpacity = 0.0
    @State private var subtitleOpacity = 0.0
    @State private var cardsOpacity = 0.0
    @State private var cardsOffset: CGFloat = 20
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let questions = [
        "Why did the Gold Rush start?",
        "What was life like for miners?",
        "Who became rich during the Gold Rush?",
        "How did Chinese immigrants contribute?",
        "What happened after the Gold Rush ended?",
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: GoldRushTheme.Spacing.lg) {
                Spacer(minLength: GoldRushTheme.Spacing.xl)

                animatedOrb

                VStack(spacing: GoldRushTheme.Spacing.xs) {
                    Text("Your Gold Rush Guide")
                        .font(GoldRushTheme.Typography.heading(24))
                        .foregroundStyle(GoldRushTheme.Colors.parchment)
                        .opacity(titleOpacity)

                    Text("Ask me anything about the California Gold Rush —\nminers, maps, money, and myths.")
                        .font(GoldRushTheme.Typography.body(15))
                        .foregroundStyle(GoldRushTheme.Colors.ironGray)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, GoldRushTheme.Spacing.xl)
                        .opacity(subtitleOpacity)
                }

                suggestedCards
                    .opacity(cardsOpacity)
                    .offset(y: cardsOffset)

                Spacer(minLength: GoldRushTheme.Spacing.xl)
            }
        }
        .scrollIndicators(.hidden)
        .task { await animateIn() }
    }

    private var animatedOrb: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .strokeBorder(
                        GoldRushTheme.Colors.richGold.opacity(ringOpacity[i]),
                        lineWidth: 1.5 - CGFloat(i) * 0.4
                    )
                    .frame(
                        width: CGFloat(80 + i * 36),
                        height: CGFloat(80 + i * 36)
                    )
                    .scaleEffect(ringScale[i])
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            GoldRushTheme.Colors.richGold.opacity(0.35),
                            GoldRushTheme.Colors.deepBrown.opacity(0.8),
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 38
                    )
                )
                .frame(width: 80, height: 80)
                .scaleEffect(orbPulse ? 1.06 : 1.0)
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                    value: orbPulse
                )

            Image(systemName: "sparkles")
                .font(.system(size: 34))
                .foregroundStyle(GoldRushTheme.Gradients.goldShimmer)
                .scaleEffect(orbPulse ? 1.08 : 1.0)
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                    value: orbPulse
                )
        }
        .frame(height: 160)
    }

    private var suggestedCards: some View {
        VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.xs) {
            Text("Try asking:")
                .font(GoldRushTheme.Typography.caption(12))
                .foregroundStyle(GoldRushTheme.Colors.ironGray)
                .padding(.horizontal, GoldRushTheme.Spacing.xl)

            VStack(spacing: GoldRushTheme.Spacing.xs) {
                ForEach(Array(questions.enumerated()), id: \.offset) { index, question in
                    SuggestedQuestionCard(
                        question: question,
                        delay: Double(index) * 0.07,
                        onSelect: onSelect
                    )
                }
            }
            .padding(.horizontal, GoldRushTheme.Spacing.xl)
        }
    }

    private func animateIn() async {
        orbPulse = true

        if reduceMotion {
            titleOpacity = 1
            subtitleOpacity = 1
            cardsOpacity = 1
            cardsOffset = 0
            for i in 0..<3 {
                ringScale[i] = 1
            }
            return
        }

        try? await Task.sleep(for: .milliseconds(150))
        withAnimation(.easeOut(duration: 0.4)) { titleOpacity = 1 }
        try? await Task.sleep(for: .milliseconds(150))
        withAnimation(.easeOut(duration: 0.4)) { subtitleOpacity = 1 }
        try? await Task.sleep(for: .milliseconds(200))
        withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
            cardsOpacity = 1
            cardsOffset = 0
        }

        for i in 0..<3 {
            withAnimation(
                .easeOut(duration: 2.5)
                .repeatForever(autoreverses: false)
                .delay(Double(i) * 0.6)
            ) {
                ringScale[i] = 1.6
                ringOpacity[i] = 0
            }
        }
    }
}

private struct SuggestedQuestionCard: View {
    let question: String
    let delay: Double
    let onSelect: (String) -> Void

    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: { onSelect(question) }) {
            HStack {
                Image(systemName: "arrow.turn.down.right")
                    .font(.system(size: 11))
                    .foregroundStyle(GoldRushTheme.Colors.richGold.opacity(0.6))
                Text(question)
                    .font(GoldRushTheme.Typography.body(14))
                    .foregroundStyle(GoldRushTheme.Colors.parchment)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, GoldRushTheme.Spacing.xs)
            .padding(.horizontal, GoldRushTheme.Spacing.md)
            .background(GoldRushTheme.Colors.deepBrown.opacity(0.7))
            .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.md))
            .overlay {
                RoundedRectangle(cornerRadius: GoldRushTheme.Radius.md)
                    .strokeBorder(GoldRushTheme.Colors.richGold.opacity(0.2), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .task {
            if reduceMotion {
                appeared = true
                return
            }
            try? await Task.sleep(for: .seconds(delay))
            withAnimation(.spring(duration: 0.4, bounce: 0.15)) {
                appeared = true
            }
        }
    }
}

// MARK: - Message List Sub-views

private struct ClearHistoryButton: View {
    let onClear: () -> Void

    var body: some View {
        Button("Clear conversation", systemImage: "trash", action: onClear)
            .font(GoldRushTheme.Typography.caption(12))
            .foregroundStyle(GoldRushTheme.Colors.ironGray)
            .labelStyle(.titleAndIcon)
            .padding(.top, GoldRushTheme.Spacing.md)
    }
}

private struct MessageBubble: View {
    let message: AIMessage

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: GoldRushTheme.Spacing.xs) {
            if isUser { Spacer() }

            VStack(alignment: isUser ? .trailing : .leading, spacing: GoldRushTheme.Spacing.xxs) {
                if !isUser && message.isAIGenerated {
                    aiLabel
                }
                Text(message.content)
                    .font(GoldRushTheme.Typography.body(15))
                    .foregroundStyle(isUser ? GoldRushTheme.Colors.darkCharcoal : GoldRushTheme.Colors.deepBrown)
                    .padding(GoldRushTheme.Spacing.sm)
                    .background(isUser
                                ? AnyShapeStyle(GoldRushTheme.Gradients.goldShimmer)
                                : AnyShapeStyle(GoldRushTheme.Colors.parchment))
                    .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.md))
                    .lineSpacing(3)
            }
            .frame(maxWidth: 280, alignment: isUser ? .trailing : .leading)

            if !isUser { Spacer() }
        }
    }

    private var aiLabel: some View {
        Label("AI Generated", systemImage: "sparkles")
            .font(GoldRushTheme.Typography.caption(10))
            .foregroundStyle(GoldRushTheme.Colors.richGold)
            .labelStyle(.titleAndIcon)
    }
}

private struct ThinkingBubble: View {
    @State private var phase: Int = 0

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(GoldRushTheme.Colors.richGold)
                        .frame(width: 8, height: 8)
                        .scaleEffect(phase == i ? 1.3 : 0.8)
                        .opacity(phase == i ? 1.0 : 0.4)
                        .animation(.spring(duration: 0.3), value: phase)
                }
            }
            .padding(GoldRushTheme.Spacing.sm)
            .background(GoldRushTheme.Colors.parchment)
            .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.md))
            Spacer()
        }
        .task {
            while !Task.isCancelled {
                for i in 0..<3 {
                    phase = i
                    try? await Task.sleep(for: .milliseconds(300))
                }
            }
        }
    }
}

private struct FreeLimitBanner: View {
    let onUpgrade: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(GoldRushTheme.Colors.mutedOrange)
            Text("Free limit reached. Responses now use the knowledge base.")
                .font(GoldRushTheme.Typography.caption(12))
                .foregroundStyle(GoldRushTheme.Colors.parchment)
            Spacer()
            Button("Upgrade", action: onUpgrade)
                .font(GoldRushTheme.Typography.caption(12))
                .foregroundStyle(GoldRushTheme.Colors.richGold)
        }
        .padding(GoldRushTheme.Spacing.sm)
        .background(GoldRushTheme.Colors.deepBrown)
    }
}

private struct VoiceButton: View {
    let isActive: Bool
    let isAuthorized: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(isActive ? "Stop Voice" : "Voice Input", systemImage: isActive ? "mic.fill" : "mic") {
            onToggle()
        }
        .labelStyle(.iconOnly)
        .font(.system(size: 20))
        .foregroundStyle(isActive ? GoldRushTheme.Colors.crimsonRed : GoldRushTheme.Colors.richGold)
        .frame(width: 44, height: 44)
        .background(GoldRushTheme.Colors.deepBrown.opacity(0.7))
        .clipShape(.circle)
        .disabled(!isAuthorized)
        .animation(.spring(duration: 0.2), value: isActive)
    }
}

private struct SendButton: View {
    let isEnabled: Bool
    let onSend: () -> Void

    var body: some View {
        Button("Send", systemImage: "arrow.up", action: onSend)
            .labelStyle(.iconOnly)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(isEnabled ? GoldRushTheme.Colors.darkCharcoal : GoldRushTheme.Colors.ironGray)
            .frame(width: 44, height: 44)
            .background(isEnabled ? GoldRushTheme.Colors.richGold : GoldRushTheme.Colors.deepBrown)
            .clipShape(.circle)
            .disabled(!isEnabled)
            .animation(.spring(duration: 0.2), value: isEnabled)
    }
}
