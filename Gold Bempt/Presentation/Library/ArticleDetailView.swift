import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    let viewModel: LibraryViewModel?
    let hasHistorianPack: Bool
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @State private var showUpgradeSheet = false

    private var previewText: String {
        let words = article.body.split(separator: " ")
        let preview = words.prefix(60).joined(separator: " ")
        return preview + (words.count > 60 ? "…" : "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GoldRushTheme.Gradients.parchmentBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.lg) {
                        articleHeader
                        Divider()
                            .background(GoldRushTheme.Colors.parchmentDark)
                        articleBody
                        if !hasHistorianPack {
                            paywallTeaser
                        } else {
                            tagRow
                        }
                    }
                    .padding(.horizontal, GoldRushTheme.Spacing.lg)
                    .padding(.top, GoldRushTheme.Spacing.md)
                    .padding(.bottom, GoldRushTheme.Spacing.xxl)
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(GoldRushTheme.Colors.parchmentDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done", action: dismiss.callAsFunction)
                        .foregroundStyle(GoldRushTheme.Colors.deepBrown)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    bookmarkButton
                }
            }
        }
        .onAppear { viewModel?.markRead(article) }
        .sheet(isPresented: $showUpgradeSheet) {
            HistorianPackPromptView()
                .environment(coordinator)
        }
    }

    @ViewBuilder
    private var bookmarkButton: some View {
        if hasHistorianPack {
            Button(
                article.isBookmarked ? "Bookmarked" : "Bookmark",
                systemImage: article.isBookmarked ? "bookmark.fill" : "bookmark"
            ) {
                viewModel?.toggleBookmark(for: article)
            }
            .foregroundStyle(GoldRushTheme.Colors.richGold)
        } else {
            Button("Bookmark", systemImage: "bookmark") {
                showUpgradeSheet = true
            }
            .foregroundStyle(GoldRushTheme.Colors.ironGray)
        }
    }

    private var articleHeader: some View {
        VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.sm) {
            HStack {
                Text(article.category.rawValue.uppercased())
                    .font(GoldRushTheme.Typography.caption(11))
                    .foregroundStyle(GoldRushTheme.Colors.richGold)
                    .tracking(1.5)
                Spacer()
                Text(article.yearContext)
                    .font(GoldRushTheme.Typography.caption(11))
                    .foregroundStyle(GoldRushTheme.Colors.ironGray)
            }

            Text(article.title)
                .font(GoldRushTheme.Typography.display(26))
                .foregroundStyle(GoldRushTheme.Colors.deepBrown)
                .lineSpacing(4)

            Text(article.subtitle)
                .font(GoldRushTheme.Typography.heading(16))
                .foregroundStyle(GoldRushTheme.Colors.ironGray)
                .lineSpacing(3)

            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 13))
                Text("\(article.readTimeMinutes) minute read")
                    .font(GoldRushTheme.Typography.caption())
            }
            .foregroundStyle(GoldRushTheme.Colors.ironGray)
        }
    }

    @ViewBuilder
    private var articleBody: some View {
        if hasHistorianPack {
            Text(article.body)
                .font(GoldRushTheme.Typography.body(16))
                .foregroundStyle(GoldRushTheme.Colors.deepBrown)
                .lineSpacing(7)
        } else {
            ZStack(alignment: .bottom) {
                Text(previewText)
                    .font(GoldRushTheme.Typography.body(16))
                    .foregroundStyle(GoldRushTheme.Colors.deepBrown)
                    .lineSpacing(7)

                LinearGradient(
                    colors: [.clear, GoldRushTheme.Colors.parchment.opacity(0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 80)
            }
        }
    }

    private var tagRow: some View {
        FlowRow(tags: article.tags)
    }

    private var paywallTeaser: some View {
        VStack(spacing: GoldRushTheme.Spacing.md) {
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 32))
                .foregroundStyle(GoldRushTheme.Colors.richGold)

            Text("Full article in Historian Pack")
                .font(GoldRushTheme.Typography.heading(17))
                .foregroundStyle(GoldRushTheme.Colors.deepBrown)

            Text("Unlock the complete text, plus bookmarks and all 20 articles.")
                .font(GoldRushTheme.Typography.body(14))
                .foregroundStyle(GoldRushTheme.Colors.ironGray)
                .multilineTextAlignment(.center)

            Button("Unlock Historian Pack") { showUpgradeSheet = true }
                .font(GoldRushTheme.Typography.heading(15))
                .foregroundStyle(GoldRushTheme.Colors.darkCharcoal)
                .padding(.vertical, GoldRushTheme.Spacing.sm)
                .padding(.horizontal, GoldRushTheme.Spacing.lg)
                .background(GoldRushTheme.Gradients.goldShimmer)
                .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.md))
        }
        .padding(GoldRushTheme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(GoldRushTheme.Colors.parchmentDark.opacity(0.5))
        .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.md))
    }
}

// MARK: - Historian Pack Upgrade Prompt

private struct HistorianPackPromptView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                GoldRushTheme.Gradients.darkBackground.ignoresSafeArea()
                VStack(spacing: GoldRushTheme.Spacing.lg) {
                    Spacer()
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(GoldRushTheme.Gradients.goldShimmer)
                    Text("Historian Pack")
                        .font(GoldRushTheme.Typography.display(28))
                        .foregroundStyle(GoldRushTheme.Colors.parchment)
                    Text("Read full articles and save bookmarks with a one-time purchase.")
                        .font(GoldRushTheme.Typography.body(15))
                        .foregroundStyle(GoldRushTheme.Colors.ironGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, GoldRushTheme.Spacing.xl)
                    GoldButton(title: "Go to Store") {
                        dismiss()
                        coordinator.navigateTo(.profile)
                    }
                    .padding(.horizontal, GoldRushTheme.Spacing.xl)
                    GoldButton(title: "Not Now", action: dismiss.callAsFunction, style: .secondary)
                        .padding(.horizontal, GoldRushTheme.Spacing.xl)
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", action: dismiss.callAsFunction)
                        .foregroundStyle(GoldRushTheme.Colors.ironGray)
                }
            }
        }
    }
}

// MARK: - Flow Row

private struct FlowRow: View {
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.xs) {
            Text("TOPICS")
                .font(GoldRushTheme.Typography.caption(10))
                .foregroundStyle(GoldRushTheme.Colors.richGold)
                .tracking(2)

            LazyVGrid(
                columns: Array(repeating: GridItem(.adaptive(minimum: 80), spacing: GoldRushTheme.Spacing.xs), count: 3),
                spacing: GoldRushTheme.Spacing.xs
            ) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(GoldRushTheme.Typography.caption(11))
                        .foregroundStyle(GoldRushTheme.Colors.deepBrown)
                        .padding(.vertical, GoldRushTheme.Spacing.xxs)
                        .padding(.horizontal, GoldRushTheme.Spacing.xs)
                        .background(GoldRushTheme.Colors.parchmentDark)
                        .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.sm))
                        .lineLimit(1)
                }
            }
        }
    }
}
