import SwiftUI

#Preview {
    ProfileView()
        .environment(AppCoordinator())
}

struct ProfileView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel: ProfileViewModel?
    @State private var showStore = false
    @State private var showIconPicker = false
    @State private var editingName = false
    @State private var nameInput = ""

    var body: some View {
        NavigationStack {
            ZStack {
                GoldRushTheme.Gradients.darkBackground
                    .ignoresSafeArea()

                if let vm = viewModel {
                    profileContent(vm: vm)
                } else {
                    ProgressView().tint(GoldRushTheme.Colors.richGold)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(GoldRushTheme.Colors.darkCharcoal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Upgrades", systemImage: "cart.fill") { showStore = true }
                        .foregroundStyle(GoldRushTheme.Colors.richGold)
                }
            }
            .sheet(isPresented: $showStore) {
                StoreView().environment(coordinator)
            }
            .sheet(isPresented: $showIconPicker) {
                if let vm = viewModel {
                    IconPickerSheet(
                        selectedIcon: vm.progress.playerIconName,
                        onSelect: { icon in
                            vm.updateIcon(icon)
                            showIconPicker = false
                        }
                    )
                }
            }
        }
        .task {
            let vm = ProfileViewModel(progressUseCase: coordinator.progressUseCase)
            vm.load()
            viewModel = vm
        }
    }

    private func profileContent(vm: ProfileViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: GoldRushTheme.Spacing.lg) {
                playerHeader(vm: vm)
                    .padding(.horizontal, GoldRushTheme.Spacing.md)

                statsRings(vm: vm)
                    .padding(.horizontal, GoldRushTheme.Spacing.md)

                achievementSection(vm: vm)
                    .padding(.horizontal, GoldRushTheme.Spacing.md)
                    .padding(.bottom, GoldRushTheme.Spacing.xxl)
            }
            .padding(.top, GoldRushTheme.Spacing.md)
        }
        .scrollIndicators(.hidden)
    }

    private func playerHeader(vm: ProfileViewModel) -> some View {
        DarkCard {
            VStack(spacing: GoldRushTheme.Spacing.md) {
                PlayerAvatarView(iconName: vm.progress.playerIconName, onTap: { showIconPicker = true })

                if editingName {
                    nameEditField(vm: vm)
                } else {
                    playerNameDisplay(vm: vm)
                }

                HStack(spacing: GoldRushTheme.Spacing.lg) {
                    PlayerBadge(icon: "star.fill",  value: "\(vm.progress.totalPoints)", label: "points")
                    PlayerBadge(icon: "bolt.fill",   value: "\(vm.progress.quizzesCompleted)", label: "quizzes")
                    PlayerBadge(icon: "flame.fill",  value: "\(vm.progress.longestStreak)x", label: "streak")
                }
            }
            .padding(GoldRushTheme.Spacing.lg)
            .frame(maxWidth: .infinity)
        }
    }

    private func playerNameDisplay(vm: ProfileViewModel) -> some View {
        Button {
            nameInput = vm.progress.playerName
            editingName = true
        } label: {
            HStack(spacing: 6) {
                Text(vm.progress.playerName)
                    .font(GoldRushTheme.Typography.heading(20))
                    .foregroundStyle(GoldRushTheme.Colors.parchment)
                Image(systemName: "pencil")
                    .font(.system(size: 13))
                    .foregroundStyle(GoldRushTheme.Colors.ironGray)
            }
        }
        .buttonStyle(.plain)
    }

    private func nameEditField(vm: ProfileViewModel) -> some View {
        HStack(spacing: GoldRushTheme.Spacing.xs) {
            TextField("Your name", text: $nameInput)
                .font(GoldRushTheme.Typography.heading(18))
                .foregroundStyle(GoldRushTheme.Colors.parchment)
                .multilineTextAlignment(.center)
                .padding(.vertical, GoldRushTheme.Spacing.xs)
                .padding(.horizontal, GoldRushTheme.Spacing.sm)
                .background(GoldRushTheme.Colors.deepBrown.opacity(0.8))
                .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.md))
                .overlay {
                    RoundedRectangle(cornerRadius: GoldRushTheme.Radius.md)
                        .strokeBorder(GoldRushTheme.Colors.richGold.opacity(0.5), lineWidth: 1)
                }
                .onSubmit {
                    vm.updateName(nameInput)
                    editingName = false
                }

            Button("Done") {
                vm.updateName(nameInput)
                editingName = false
            }
            .font(GoldRushTheme.Typography.caption(13))
            .foregroundStyle(GoldRushTheme.Colors.richGold)
        }
        .padding(.horizontal, GoldRushTheme.Spacing.md)
    }

    private func statsRings(vm: ProfileViewModel) -> some View {
        DarkCard {
            HStack(spacing: GoldRushTheme.Spacing.lg) {
                StatRingTile(
                    label: "Accuracy",
                    value: "\(vm.progress.accuracyPercent)%",
                    fraction: vm.progress.accuracy
                )
                Divider().background(GoldRushTheme.Colors.ironGray.opacity(0.3))
                    .frame(height: 80)
                StatRingTile(
                    label: "Topics",
                    value: "\(vm.progress.topicsCompleted.count)/\(QuizTopic.allCases.count)",
                    fraction: Double(vm.progress.topicsCompleted.count) / Double(QuizTopic.allCases.count)
                )
                Divider().background(GoldRushTheme.Colors.ironGray.opacity(0.3))
                    .frame(height: 80)
                StatRingTile(
                    label: "Articles",
                    value: "\(vm.progress.articlesRead.count)",
                    fraction: min(Double(vm.progress.articlesRead.count) / 20, 1)
                )
            }
            .padding(GoldRushTheme.Spacing.lg)
        }
    }

    private func achievementSection(vm: ProfileViewModel) -> some View {
        VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.sm) {
            HStack {
                Text("ACHIEVEMENTS")
                    .font(GoldRushTheme.Typography.caption(11))
                    .foregroundStyle(GoldRushTheme.Colors.richGold)
                    .tracking(2)
                Spacer()
                Text("\(vm.unlockedAchievements.count) of \(vm.achievements.count)")
                    .font(GoldRushTheme.Typography.caption(12))
                    .foregroundStyle(GoldRushTheme.Colors.ironGray)
            }

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: GoldRushTheme.Spacing.sm
            ) {
                ForEach(Array(vm.achievements.enumerated()), id: \.element.id) { index, achievement in
                    AchievementTile(achievement: achievement, index: index)
                }
            }
        }
    }
}

// MARK: - Sub-views

private struct PlayerAvatarView: View {
    let iconName: String
    let onTap: () -> Void

    @State private var rotation: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                GoldRushTheme.Colors.richGold.opacity(0.25),
                                GoldRushTheme.Colors.deepBrown,
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 44
                        )
                    )
                    .frame(width: 88, height: 88)
                Circle()
                    .strokeBorder(
                        AngularGradient(
                            colors: [
                                GoldRushTheme.Colors.richGold.opacity(0.8),
                                GoldRushTheme.Colors.richGold.opacity(0.1),
                                GoldRushTheme.Colors.richGold.opacity(0.8),
                            ],
                            center: .center
                        ),
                        lineWidth: 2.5
                    )
                    .frame(width: 92, height: 92)
                    .rotationEffect(.degrees(rotation))
                    .animation(
                        reduceMotion ? nil : .linear(duration: 5).repeatForever(autoreverses: false),
                        value: rotation
                    )
                Image(systemName: iconName)
                    .font(.system(size: 36))
                    .foregroundStyle(GoldRushTheme.Gradients.goldShimmer)
            }
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(GoldRushTheme.Colors.richGold)
                    .background(GoldRushTheme.Colors.darkCharcoal, in: .circle)
                    .offset(x: 4, y: 4)
            }
        }
        .buttonStyle(.plain)
        .task { rotation = 360 }
    }
}

private struct PlayerBadge: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(GoldRushTheme.Colors.richGold)
                Text(value)
                    .font(GoldRushTheme.Typography.heading(15))
                    .foregroundStyle(GoldRushTheme.Colors.parchment)
            }
            Text(label)
                .font(GoldRushTheme.Typography.caption(10))
                .foregroundStyle(GoldRushTheme.Colors.ironGray)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct StatRingTile: View {
    let label: String
    let value: String
    let fraction: Double

    @State private var displayFraction: Double = 0

    var body: some View {
        VStack(spacing: GoldRushTheme.Spacing.xs) {
            ProgressRing(value: displayFraction, total: 1.0, lineWidth: 6)
                .frame(width: 56, height: 56)
                .overlay {
                    Text(value)
                        .font(GoldRushTheme.Typography.caption(11))
                        .foregroundStyle(GoldRushTheme.Colors.parchment)
                }
            Text(label)
                .font(GoldRushTheme.Typography.caption(11))
                .foregroundStyle(GoldRushTheme.Colors.ironGray)
        }
        .frame(maxWidth: .infinity)
        .task {
            try? await Task.sleep(for: .milliseconds(400))
            withAnimation(.spring(duration: 1.0, bounce: 0.15)) { displayFraction = fraction }
        }
    }
}

private struct AchievementTile: View {
    let achievement: Achievement
    let index: Int

    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        DarkCard {
            HStack(spacing: GoldRushTheme.Spacing.sm) {
                Image(systemName: achievement.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(achievement.isUnlocked
                                     ? AnyShapeStyle(GoldRushTheme.Gradients.goldShimmer)
                                     : AnyShapeStyle(GoldRushTheme.Colors.ironGray.opacity(0.4)))
                    .frame(width: 44)

                VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.xxs) {
                    Text(achievement.title)
                        .font(GoldRushTheme.Typography.caption(13))
                        .foregroundStyle(achievement.isUnlocked
                                         ? GoldRushTheme.Colors.parchment
                                         : GoldRushTheme.Colors.ironGray)
                    Text(achievement.description)
                        .font(GoldRushTheme.Typography.caption(11))
                        .foregroundStyle(GoldRushTheme.Colors.ironGray.opacity(0.7))
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(GoldRushTheme.Spacing.sm)
            .opacity(achievement.isUnlocked ? 1.0 : 0.55)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .task {
            if reduceMotion { appeared = true; return }
            try? await Task.sleep(for: .seconds(Double(index) * 0.06 + 0.2))
            withAnimation(.spring(duration: 0.45, bounce: 0.2)) { appeared = true }
        }
    }
}

// MARK: - Icon Picker Sheet

private struct IconPickerSheet: View {
    let selectedIcon: String
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    private let icons = [
        "star.fill", "flame.fill", "bolt.fill", "crown.fill",
        "trophy.fill", "map.fill", "hammer.fill", "tent.fill",
        "mountain.2.fill", "cart.fill", "leaf.fill", "figure.walk",
        "magnifyingglass", "book.fill", "banknote.fill", "compass.drawing",
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                GoldRushTheme.Gradients.darkBackground.ignoresSafeArea()

                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: 4),
                        spacing: GoldRushTheme.Spacing.md
                    ) {
                        ForEach(icons, id: \.self) { icon in
                            Button { onSelect(icon) } label: {
                                ZStack {
                                    Circle()
                                        .fill(selectedIcon == icon
                                              ? GoldRushTheme.Colors.richGold.opacity(0.2)
                                              : GoldRushTheme.Colors.deepBrown.opacity(0.6))
                                        .frame(width: 64, height: 64)
                                    if selectedIcon == icon {
                                        Circle()
                                            .strokeBorder(GoldRushTheme.Colors.richGold, lineWidth: 2)
                                            .frame(width: 64, height: 64)
                                    }
                                    Image(systemName: icon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 26, height: 26)
                                        .foregroundStyle(selectedIcon == icon
                                                         ? AnyShapeStyle(GoldRushTheme.Gradients.goldShimmer)
                                                         : AnyShapeStyle(GoldRushTheme.Colors.ironGray))
                                }
                            }
                            .buttonStyle(.plain)
                            .animation(.spring(duration: 0.2), value: selectedIcon)
                        }
                    }
                    .padding(GoldRushTheme.Spacing.lg)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(GoldRushTheme.Colors.darkCharcoal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel", action: dismiss.callAsFunction)
                        .foregroundStyle(GoldRushTheme.Colors.ironGray)
                }
            }
        }
    }
}
