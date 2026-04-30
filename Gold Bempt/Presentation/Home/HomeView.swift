import SwiftUI

struct HomeView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel: HomeViewModel?
    @State private var headerVisible = false
    @State private var showStore = false

    var body: some View {
        NavigationStack {
            ZStack {
                GoldRushTheme.Gradients.darkBackground
                    .ignoresSafeArea()

                if let vm = viewModel {
                    homeContent(vm: vm)
                } else {
                    ProgressView()
                        .tint(GoldRushTheme.Colors.richGold)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(GoldRushTheme.Colors.darkCharcoal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(GoldRushTheme.Colors.richGold)
                            .font(.system(size: 14))
                        Text("Gold Rush")
                            .font(GoldRushTheme.Typography.heading(18))
                            .foregroundStyle(GoldRushTheme.Gradients.goldShimmer)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Store", systemImage: "cart.fill") { showStore = true }
                        .foregroundStyle(GoldRushTheme.Colors.richGold)
                        .labelStyle(.iconOnly)
                }
            }
            .sheet(isPresented: $showStore) {
                StoreView()
                    .environment(coordinator)
            }
        }
        .task {
            let vm = HomeViewModel(
                libraryUseCase:  coordinator.libraryUseCase,
                progressUseCase: coordinator.progressUseCase
            )
            vm.load()
            viewModel = vm
            withAnimation(.easeOut(duration: 0.5)) {
                headerVisible = true
            }
        }
    }

    private func homeContent(vm: HomeViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: GoldRushTheme.Spacing.lg) {
                HeroBanner(
                    initialFact: vm.dailyFact,
                    points: vm.recentPoints,
                    quizzesCompleted: vm.quizzesCompleted,
                    onTapPoints: { coordinator.navigateTo(.profile) },
                    onTapQuizzes: { coordinator.navigateTo(.quiz) }
                )

                statsRow(vm: vm)
                    .padding(.horizontal, GoldRushTheme.Spacing.md)
                
                AskAIBanner(onTap: { coordinator.navigateTo(.assistant) })
                    .padding(.horizontal, GoldRushTheme.Spacing.md)

                topicProgressSection(vm: vm)
                    .padding(.horizontal, GoldRushTheme.Spacing.md)

                StatsChartSection(
                    recentScores: vm.recentScores,
                    topicMastery: vm.topicMastery
                )
                .padding(.horizontal, GoldRushTheme.Spacing.md)

                QuickStartCard(onStart: { coordinator.navigateTo(.quiz) })
                    .padding(.horizontal, GoldRushTheme.Spacing.md)

                if !vm.recentArticles.isEmpty {
                    recentArticlesSection(vm: vm)
                }
            }
            .padding(.vertical, GoldRushTheme.Spacing.sm)
            // .padding(.bottom, GoldRushTheme.Spacing.xxxl)
        }
        .scrollIndicators(.hidden)
    }

    private func statsRow(vm: HomeViewModel) -> some View {
        HStack(spacing: GoldRushTheme.Spacing.sm) {
            StatTile(
                icon: "target",
                title: "Accuracy",
                value: "\(Int(vm.recentAccuracy * 100))%",
                color: GoldRushTheme.Colors.richGold
            )
            StatTile(
                icon: "star.fill",
                title: "Points",
                value: "\(vm.recentPoints)",
                color: GoldRushTheme.Colors.brightGold
            )
            StatTile(
                icon: "flame.fill",
                title: "Streak",
                value: "\(vm.totalStreak)x",
                color: GoldRushTheme.Colors.mutedOrange
            )
        }
    }

    private func topicProgressSection(vm: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.sm) {
            SectionHeader(title: "TOPICS", subtitle: "\(vm.topicProgress.filter(\.isCompleted).count) of \(vm.topicProgress.count) completed")

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: GoldRushTheme.Spacing.sm
            ) {
                ForEach(Array(vm.topicProgress.enumerated()), id: \.element.topic.id) { index, item in
                    TopicProgressTile(topic: item.topic, isCompleted: item.isCompleted, index: index) {
                        coordinator.navigateTo(.quiz)
                    }
                }
            }
        }
    }

    private func recentArticlesSection(vm: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.sm) {
            SectionHeader(title: "LIBRARY", subtitle: "Explore the era")
                .padding(.horizontal, GoldRushTheme.Spacing.md)

            ScrollView(.horizontal) {
                HStack(spacing: GoldRushTheme.Spacing.sm) {
                    ForEach(vm.recentArticles) { article in
                        ArticlePreviewCard(article: article) {
                            coordinator.navigateTo(.library)
                        }
                    }
                }
                .padding(.horizontal, GoldRushTheme.Spacing.md)
            }
            .scrollIndicators(.hidden)
        }
    }
}

// MARK: - Sub-views

private struct HeroBanner: View {
    let initialFact: String
    let points: Int
    let quizzesCompleted: Int
    let onTapPoints: () -> Void
    let onTapQuizzes: () -> Void

    private static let facts = [
        "Gold is so dense that a cubic foot of it weighs over half a ton.",
        "James Marshall, who discovered gold at Sutter's Mill, died penniless in 1885.",
        "San Francisco's population jumped from 1,000 to 25,000 in just two years.",
        "Sam Brannan became California's first millionaire by selling supplies, not mining gold.",
        "Women made up fewer than 8% of California's Gold Rush population.",
        "Levi Strauss's famous riveted denim pants were patented in 1873.",
        "Over 300,000 people migrated to California between 1848 and 1855.",
        "Fool's gold (iron pyrite) is 7 times lighter than real gold.",
        "The phrase 'pan out' originated in Gold Rush placer mining.",
        "California's state motto 'Eureka' means 'I have found it' in Greek.",
    ]

    @State private var factIndex: Int = 0
    @State private var shimmerOffset: CGFloat = -200
    @State private var glowPulse = false
    @State private var factDirection: Int = 1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var currentFact: String { Self.facts[factIndex] }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: GoldRushTheme.Radius.xl)
                .fill(
                    LinearGradient(
                        colors: [
                            GoldRushTheme.Colors.deepBrown,
                            Color(red: 0.18, green: 0.12, blue: 0.05),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: GoldRushTheme.Radius.xl)
                .fill(
                    LinearGradient(
                        colors: [
                            GoldRushTheme.Colors.richGold.opacity(0.15),
                            Color.clear,
                            GoldRushTheme.Colors.richGold.opacity(0.05),
                        ],
                        startPoint: UnitPoint(x: shimmerOffset / 400, y: 0),
                        endPoint: UnitPoint(x: (shimmerOffset + 200) / 400, y: 1)
                    )
                )
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("California Gold Rush")
                            .font(GoldRushTheme.Typography.caption(11))
                            .foregroundStyle(GoldRushTheme.Colors.richGold)
                            .tracking(2)
                        Text("Quizzes & History")
                            .font(GoldRushTheme.Typography.display(26))
                            .foregroundStyle(GoldRushTheme.Colors.parchment)
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(GoldRushTheme.Colors.richGold.opacity(glowPulse ? 0.25 : 0.1))
                            .frame(width: 64, height: 64)
                            .scaleEffect(glowPulse ? 1.15 : 1.0)
                            .animation(
                                reduceMotion ? nil : .easeInOut(duration: 2).repeatForever(autoreverses: true),
                                value: glowPulse
                            )
                        Image(systemName: "flame.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(GoldRushTheme.Gradients.goldShimmer)
                    }
                }

                Divider()
                    .overlay(GoldRushTheme.Colors.richGold.opacity(0.2))

                Button(action: advanceFact) {
                    HStack(alignment: .top, spacing: GoldRushTheme.Spacing.xs) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(GoldRushTheme.Colors.richGold)
                            .font(.system(size: 13))
                            .padding(.top, 2)

                        Text(currentFact)
                            .font(GoldRushTheme.Typography.body(14))
                            .foregroundStyle(GoldRushTheme.Colors.parchment.opacity(0.9))
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id(factIndex)
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: factDirection > 0 ? .trailing : .leading).combined(with: .opacity),
                                    removal:   .move(edge: factDirection > 0 ? .leading  : .trailing).combined(with: .opacity)
                                )
                            )

                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11))
                            .foregroundStyle(GoldRushTheme.Colors.ironGray.opacity(0.6))
                            .padding(.top, 3)
                    }
                }
                .buttonStyle(.plain)
                .gesture(
                    DragGesture(minimumDistance: 30)
                        .onEnded { value in
                            if value.translation.width < 0 {
                                factDirection = 1
                            } else {
                                factDirection = -1
                            }
                            withAnimation(.spring(duration: 0.35)) {
                                factIndex = (factIndex + Self.facts.count + factDirection) % Self.facts.count
                            }
                        }
                )

                HStack(spacing: GoldRushTheme.Spacing.sm) {
                    Button(action: onTapPoints) {
                        HeroBadge(icon: "star.fill", value: "\(points)", label: "pts")
                    }
                    .buttonStyle(.plain)
                    Button(action: onTapQuizzes) {
                        HeroBadge(icon: "bolt.fill", value: "\(quizzesCompleted)", label: "quizzes")
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("\(factIndex + 1)/\(Self.facts.count)")
                        .font(GoldRushTheme.Typography.caption(10))
                        .foregroundStyle(GoldRushTheme.Colors.ironGray.opacity(0.5))
                }
            }
            .padding(GoldRushTheme.Spacing.lg)
        }
        .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.xl))
        .overlay {
            RoundedRectangle(cornerRadius: GoldRushTheme.Radius.xl)
                .strokeBorder(GoldRushTheme.Colors.richGold.opacity(0.3), lineWidth: 1)
        }
        .padding(.horizontal, GoldRushTheme.Spacing.md)
        .task {
            if let idx = Self.facts.firstIndex(of: initialFact) { factIndex = idx }
            glowPulse = true
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false).delay(0.5)) {
                shimmerOffset = 400
            }
        }
    }

    private func advanceFact() {
        factDirection = 1
        withAnimation(.spring(duration: 0.35)) {
            factIndex = (factIndex + 1) % Self.facts.count
        }
    }
}

private struct HeroBadge: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(GoldRushTheme.Colors.richGold)
            Text("\(value) \(label)")
                .font(GoldRushTheme.Typography.caption(12))
                .foregroundStyle(GoldRushTheme.Colors.ironGray)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, GoldRushTheme.Spacing.xs)
        .background(GoldRushTheme.Colors.darkCharcoal.opacity(0.5))
        .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.sm))
    }
}

private struct SectionHeader: View {
    let title: String
    let subtitle: String

    @State private var visible = false

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(GoldRushTheme.Typography.caption(11))
                .foregroundStyle(GoldRushTheme.Colors.richGold)
                .tracking(2)
            Spacer()
            Text(subtitle)
                .font(GoldRushTheme.Typography.caption(12))
                .foregroundStyle(GoldRushTheme.Colors.ironGray)
        }
        .opacity(visible ? 1 : 0)
        .offset(x: visible ? 0 : -8)
        .onAppear { withAnimation(.easeOut(duration: 0.4)) { visible = true } }
    }
}

private struct StatTile: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        DarkCard {
            VStack(spacing: GoldRushTheme.Spacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                Text(value)
                    .font(GoldRushTheme.Typography.display(22))
                    .foregroundStyle(GoldRushTheme.Colors.parchment)
                Text(title)
                    .font(GoldRushTheme.Typography.caption(10))
                    .foregroundStyle(GoldRushTheme.Colors.ironGray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, GoldRushTheme.Spacing.sm)
            .padding(.horizontal, GoldRushTheme.Spacing.xs)
        }
        .scaleEffect(appeared ? 1.0 : 0.8)
        .opacity(appeared ? 1.0 : 0.0)
        .task {
            guard !reduceMotion else { appeared = true; return }
            try? await Task.sleep(for: .milliseconds(150))
            withAnimation(.spring(duration: 0.5, bounce: 0.35)) { appeared = true }
        }
    }
}

private struct TopicProgressTile: View {
    let topic: QuizTopic
    let isCompleted: Bool
    let index: Int
    let onTap: () -> Void

    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: GoldRushTheme.Spacing.xs) {
                ZStack {
                    Circle()
                        .fill(isCompleted
                              ? GoldRushTheme.Colors.richGold.opacity(0.2)
                              : GoldRushTheme.Colors.deepBrown.opacity(0.6))
                        .frame(width: 48, height: 48)
                    if isCompleted {
                        Circle()
                            .strokeBorder(GoldRushTheme.Colors.richGold.opacity(0.6), lineWidth: 1.5)
                            .frame(width: 48, height: 48)
                    }
                    Image(systemName: topic.iconName)
                        .font(.system(size: 20))
                        .foregroundStyle(isCompleted
                                         ? GoldRushTheme.Colors.richGold
                                         : GoldRushTheme.Colors.ironGray)
                }
                Text(topic.rawValue)
                    .font(GoldRushTheme.Typography.caption(10))
                    .foregroundStyle(isCompleted
                                     ? GoldRushTheme.Colors.parchment
                                     : GoldRushTheme.Colors.ironGray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, GoldRushTheme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: GoldRushTheme.Radius.md)
                    .fill(isCompleted
                          ? GoldRushTheme.Colors.richGold.opacity(0.07)
                          : GoldRushTheme.Colors.deepBrown.opacity(0.4))
            )
            .overlay {
                RoundedRectangle(cornerRadius: GoldRushTheme.Radius.md)
                    .strokeBorder(
                        isCompleted ? GoldRushTheme.Colors.richGold.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            }
            .scaleEffect(appeared ? 1.0 : 0.75)
            .opacity(appeared ? 1.0 : 0.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.2), value: isCompleted)
        .task {
            guard !reduceMotion else { appeared = true; return }
            try? await Task.sleep(for: .seconds(Double(index) * 0.07 + 0.1))
            withAnimation(.spring(duration: 0.4, bounce: 0.3)) { appeared = true }
        }
    }
}

private struct ArticlePreviewCard: View {
    let article: Article
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.xs) {
                HStack {
                    Text(article.category.rawValue.uppercased())
                        .font(GoldRushTheme.Typography.caption(9))
                        .foregroundStyle(GoldRushTheme.Colors.richGold)
                        .tracking(1)
                    Spacer()
                    Text("\(article.readTimeMinutes)m")
                        .font(GoldRushTheme.Typography.caption(10))
                        .foregroundStyle(GoldRushTheme.Colors.ironGray)
                }
                Text(article.title)
                    .font(GoldRushTheme.Typography.heading(14))
                    .foregroundStyle(GoldRushTheme.Colors.parchment)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                Text(article.subtitle)
                    .font(GoldRushTheme.Typography.caption(12))
                    .foregroundStyle(GoldRushTheme.Colors.ironGray)
                    .lineLimit(2)
            }
            .padding(GoldRushTheme.Spacing.md)
            .frame(width: 160, height: 140)
            .background(GoldRushTheme.Colors.deepBrown.opacity(0.7))
            .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.md))
            .overlay {
                RoundedRectangle(cornerRadius: GoldRushTheme.Radius.md)
                    .strokeBorder(GoldRushTheme.Colors.richGold.opacity(0.2), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct QuickStartCard: View {
    let onStart: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: onStart) {
            DarkCard {
                HStack(spacing: GoldRushTheme.Spacing.md) {
                    VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.xs) {
                        Text("Quick Quiz")
                            .font(GoldRushTheme.Typography.heading(22))
                            .foregroundStyle(GoldRushTheme.Colors.parchment)
                        Text("10 random questions · All topics")
                            .font(GoldRushTheme.Typography.caption(13))
                            .foregroundStyle(GoldRushTheme.Colors.ironGray)
                        HStack(spacing: 4) {
                            Text("Start now")
                                .font(GoldRushTheme.Typography.caption(12))
                                .foregroundStyle(GoldRushTheme.Colors.richGold)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 11))
                                .foregroundStyle(GoldRushTheme.Colors.richGold)
                        }
                    }
                    Spacer()
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(GoldRushTheme.Gradients.goldShimmer)
                }
                .padding(GoldRushTheme.Spacing.lg)
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .medium), trigger: pressed)
    }
}

private struct AskAIBanner: View {
    let onTap: () -> Void

    @State private var sparkle = false
    @State private var bob = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: onTap) {
            DarkCard {
                HStack(spacing: GoldRushTheme.Spacing.md) {
                    ZStack {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .strokeBorder(
                                    GoldRushTheme.Colors.richGold.opacity(sparkle ? 0 : 0.3 - Double(i) * 0.08),
                                    lineWidth: 1
                                )
                                .frame(
                                    width: CGFloat(28 + i * 14),
                                    height: CGFloat(28 + i * 14)
                                )
                                .scaleEffect(sparkle ? 1.5 : 1.0)
                                .animation(
                                    reduceMotion ? nil : .easeOut(duration: 1.5)
                                        .repeatForever(autoreverses: false)
                                        .delay(Double(i) * 0.4),
                                    value: sparkle
                                )
                        }
                        Image(systemName: "sparkles")
                            .font(.system(size: 22))
                            .foregroundStyle(GoldRushTheme.Gradients.goldShimmer)
                            .offset(y: bob ? -3 : 3)
                            .animation(
                                reduceMotion ? nil : .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                                value: bob
                            )
                    }
                    .frame(width: 60)

                    VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.xxs) {
                        Text("Ask Your AI Guide")
                            .font(GoldRushTheme.Typography.heading(17))
                            .foregroundStyle(GoldRushTheme.Colors.parchment)
                        Text("On-device · Always offline · Gold Rush expert")
                            .font(GoldRushTheme.Typography.caption(12))
                            .foregroundStyle(GoldRushTheme.Colors.ironGray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundStyle(GoldRushTheme.Colors.richGold)
                }
                .padding(GoldRushTheme.Spacing.md)
            }
        }
        .buttonStyle(.plain)
        .task { sparkle = true; bob = true }
    }
}

// MARK: - Stats Charts

private struct StatsChartSection: View {
    let recentScores: [Int]
    let topicMastery: [(topic: QuizTopic, fraction: Double)]

    var body: some View {
        VStack(spacing: GoldRushTheme.Spacing.md) {
            RecentScoresChart(scores: recentScores)
            TopicMasteryChart(items: topicMastery)
        }
    }
}

private struct RecentScoresChart: View {
    let scores: [Int]

    @State private var animatedHeights: [CGFloat] = []
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let barCount = 7
    private let maxBarHeight: CGFloat = 80

    private var displayScores: [Int?] {
        let padded = Array(repeating: nil as Int?, count: max(0, barCount - scores.count))
        return padded + scores.map { Optional($0) }
    }

    private var maxScore: Int { max(scores.max() ?? 1, 1) }

    var body: some View {
        DarkCard {
            VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.sm) {
                HStack {
                    Text("RECENT QUIZZES")
                        .font(GoldRushTheme.Typography.caption(11))
                        .foregroundStyle(GoldRushTheme.Colors.richGold)
                        .tracking(2)
                    Spacer()
                    Text("\(scores.count) of \(barCount) played")
                        .font(GoldRushTheme.Typography.caption(11))
                        .foregroundStyle(GoldRushTheme.Colors.ironGray)
                }

                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(Array(displayScores.enumerated()), id: \.offset) { i, score in
                        BarColumn(
                            score: score,
                            animatedHeight: animatedHeights.indices.contains(i) ? animatedHeights[i] : 0,
                            maxHeight: maxBarHeight,
                            index: i,
                            totalBars: barCount
                        )
                    }
                }
                .frame(height: maxBarHeight + 32)
            }
            .padding(GoldRushTheme.Spacing.md)
        }
        .task {
            animatedHeights = Array(repeating: 0, count: barCount)
            guard !reduceMotion else {
                animatedHeights = displayScores.map { score in
                    guard let s = score else { return 0 }
                    return CGFloat(s) / CGFloat(maxScore) * maxBarHeight
                }
                return
            }
            try? await Task.sleep(for: .milliseconds(200))
            for (i, score) in displayScores.enumerated() {
                let target: CGFloat = score.map { CGFloat($0) / CGFloat(maxScore) * maxBarHeight } ?? 0
                try? await Task.sleep(for: .milliseconds(60))
                withAnimation(.spring(duration: 0.55, bounce: 0.2)) {
                    if i < animatedHeights.count { animatedHeights[i] = target }
                }
            }
        }
    }
}

private struct BarColumn: View {
    let score: Int?
    let animatedHeight: CGFloat
    let maxHeight: CGFloat
    let index: Int
    let totalBars: Int

    var body: some View {
        VStack(spacing: 4) {
            if let s = score, animatedHeight > 4 {
                Text("\(s)")
                    .font(GoldRushTheme.Typography.caption(9))
                    .foregroundStyle(GoldRushTheme.Colors.richGold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            } else {
                Spacer().frame(height: 12)
            }

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(GoldRushTheme.Colors.deepBrown.opacity(0.5))
                    .frame(height: maxHeight)

                if score != nil {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    GoldRushTheme.Colors.richGold.opacity(0.7),
                                    GoldRushTheme.Colors.brightGold,
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: max(animatedHeight, 0))
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(
                            GoldRushTheme.Colors.ironGray.opacity(0.2),
                            style: StrokeStyle(lineWidth: 1, dash: [3, 3])
                        )
                        .frame(height: maxHeight)
                }
            }

            Text("Q\(index + 1)")
                .font(GoldRushTheme.Typography.caption(9))
                .foregroundStyle(score != nil
                                 ? GoldRushTheme.Colors.ironGray
                                 : GoldRushTheme.Colors.ironGray.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct TopicMasteryChart: View {
    let items: [(topic: QuizTopic, fraction: Double)]

    @State private var animatedFractions: [Double] = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        DarkCard {
            VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.sm) {
                HStack {
                    Text("TOPIC MASTERY")
                        .font(GoldRushTheme.Typography.caption(11))
                        .foregroundStyle(GoldRushTheme.Colors.richGold)
                        .tracking(2)
                    Spacer()
                    Text("10 correct = mastered")
                        .font(GoldRushTheme.Typography.caption(10))
                        .foregroundStyle(GoldRushTheme.Colors.ironGray.opacity(0.6))
                }

                VStack(spacing: GoldRushTheme.Spacing.xs) {
                    ForEach(Array(items.enumerated()), id: \.element.topic.id) { i, item in
                        TopicMasteryRow(
                            topic: item.topic,
                            fraction: item.fraction,
                            animatedFraction: animatedFractions.indices.contains(i) ? animatedFractions[i] : 0
                        )
                    }
                }
            }
            .padding(GoldRushTheme.Spacing.md)
        }
        .task {
            animatedFractions = Array(repeating: 0, count: items.count)
            guard !reduceMotion else {
                animatedFractions = items.map(\.fraction)
                return
            }
            try? await Task.sleep(for: .milliseconds(300))
            for (i, item) in items.enumerated() {
                try? await Task.sleep(for: .milliseconds(70))
                withAnimation(.spring(duration: 0.6, bounce: 0.1)) {
                    if i < animatedFractions.count { animatedFractions[i] = item.fraction }
                }
            }
        }
    }
}

private struct TopicMasteryRow: View {
    let topic: QuizTopic
    let fraction: Double
    let animatedFraction: Double

    private var pct: Int { Int(fraction * 100) }
    private var isMastered: Bool { fraction >= 1.0 }

    var body: some View {
        HStack(spacing: GoldRushTheme.Spacing.sm) {
            Image(systemName: topic.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
                .foregroundStyle(isMastered
                                 ? AnyShapeStyle(GoldRushTheme.Gradients.goldShimmer)
                                 : AnyShapeStyle(GoldRushTheme.Colors.ironGray))

            Text(topic.rawValue)
                .font(GoldRushTheme.Typography.caption(12))
                .foregroundStyle(isMastered
                                 ? GoldRushTheme.Colors.parchment
                                 : GoldRushTheme.Colors.ironGray)
                .frame(width: 100, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(GoldRushTheme.Colors.deepBrown.opacity(0.6))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: isMastered
                                    ? [GoldRushTheme.Colors.richGold, GoldRushTheme.Colors.brightGold]
                                    : [GoldRushTheme.Colors.richGold.opacity(0.6), GoldRushTheme.Colors.mutedOrange.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * animatedFraction)
                }
            }
            .frame(height: 7)

            HStack(spacing: 2) {
                Text("\(pct)%")
                    .font(GoldRushTheme.Typography.caption(11))
                    .foregroundStyle(pct > 0
                                     ? GoldRushTheme.Colors.richGold
                                     : GoldRushTheme.Colors.ironGray.opacity(0.4))
                    .frame(width: 32, alignment: .trailing)
                if isMastered {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(GoldRushTheme.Colors.richGold)
                }
            }
        }
        .frame(height: 22)
    }
}
