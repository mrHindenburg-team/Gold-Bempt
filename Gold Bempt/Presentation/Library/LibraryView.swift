import SwiftUI

struct LibraryView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel: LibraryViewModel?
    @State private var selectedArticle: Article?

    var body: some View {
        NavigationStack {
            ZStack {
                GoldRushTheme.Gradients.darkBackground
                    .ignoresSafeArea()

                if let vm = viewModel {
                    libraryContent(vm: vm)
                } else {
                    ProgressView().tint(GoldRushTheme.Colors.richGold)
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(GoldRushTheme.Colors.darkCharcoal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(
                    article: article,
                    viewModel: viewModel,
                    hasHistorianPack: coordinator.storeKit.hasHistorianPack
                )
                .environment(coordinator)
            }
        }
        .task {
            let vm = LibraryViewModel(
                libraryUseCase: coordinator.libraryUseCase,
                progressUseCase: coordinator.progressUseCase
            )
            vm.load()
            viewModel = vm
        }
    }

    private func libraryContent(vm: LibraryViewModel) -> some View {
        VStack(spacing: 0) {
            searchBar(vm: vm)
                .padding(.horizontal, GoldRushTheme.Spacing.md)
                .padding(.bottom, GoldRushTheme.Spacing.sm)

            categoryFilter(vm: vm)
                .padding(.bottom, GoldRushTheme.Spacing.sm)

            articleList(vm: vm)
        }
    }

    private func searchBar(vm: LibraryViewModel) -> some View {
        @Bindable var vm = vm
        return HStack(spacing: GoldRushTheme.Spacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(GoldRushTheme.Colors.ironGray)
            TextField("Search articles…", text: $vm.searchQuery)
                .font(GoldRushTheme.Typography.body(15))
                .foregroundStyle(GoldRushTheme.Colors.parchment)
                .autocorrectionDisabled()
                .onChange(of: vm.searchQuery) { vm.applyFilter() }
        }
        .padding(GoldRushTheme.Spacing.sm)
        .background(GoldRushTheme.Colors.deepBrown.opacity(0.8))
        .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: GoldRushTheme.Radius.md)
                .strokeBorder(GoldRushTheme.Colors.richGold.opacity(0.3), lineWidth: 1)
        }
    }

    private func categoryFilter(vm: LibraryViewModel) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: GoldRushTheme.Spacing.xs) {
                CategoryChip(
                    title: "All",
                    iconName: "square.grid.2x2.fill",
                    isSelected: vm.selectedCategory == nil,
                    onSelect: { vm.selectCategory(nil) }
                )
                ForEach(ArticleCategory.allCases) { category in
                    CategoryChip(
                        title: category.rawValue,
                        iconName: category.iconName,
                        isSelected: vm.selectedCategory == category,
                        onSelect: { vm.selectCategory(category) }
                    )
                }
            }
            .padding(.horizontal, GoldRushTheme.Spacing.md)
        }
        .scrollIndicators(.hidden)
    }

    private func articleList(vm: LibraryViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: GoldRushTheme.Spacing.sm) {
                ForEach(vm.filteredArticles) { article in
                    ArticleRowCard(
                        article: article,
                        onTap: { selectedArticle = article },
                        onBookmark: { vm.toggleBookmark(for: article) }
                    )
                }
            }
            .padding(.horizontal, GoldRushTheme.Spacing.md)
            .padding(.bottom, GoldRushTheme.Spacing.xxl)
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Sub-views

private struct CategoryChip: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            Label(title, systemImage: iconName)
                .font(GoldRushTheme.Typography.caption(12))
                .foregroundStyle(isSelected
                                 ? GoldRushTheme.Colors.darkCharcoal
                                 : GoldRushTheme.Colors.parchment)
                .padding(.vertical, GoldRushTheme.Spacing.xs)
                .padding(.horizontal, GoldRushTheme.Spacing.sm)
                .background(isSelected
                             ? AnyShapeStyle(GoldRushTheme.Gradients.goldShimmer)
                             : AnyShapeStyle(GoldRushTheme.Colors.deepBrown.opacity(0.7)))
                .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.pill))
        }
        .buttonStyle(.plain)
        .animation(.spring(duration: 0.2), value: isSelected)
    }
}

private struct ArticleRowCard: View {
    let article: Article
    let onTap: () -> Void
    let onBookmark: () -> Void

    var body: some View {
        Button(action: onTap) {
            DarkCard {
                HStack(alignment: .top, spacing: GoldRushTheme.Spacing.sm) {
                    VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.xxs) {
                        HStack {
                            Text(article.category.rawValue.uppercased())
                                .font(GoldRushTheme.Typography.caption(10))
                                .foregroundStyle(GoldRushTheme.Colors.richGold)
                                .tracking(1)
                            Spacer()
                            Text("\(article.readTimeMinutes) min")
                                .font(GoldRushTheme.Typography.caption(10))
                                .foregroundStyle(GoldRushTheme.Colors.ironGray)
                        }

                        Text(article.title)
                            .font(GoldRushTheme.Typography.heading(16))
                            .foregroundStyle(GoldRushTheme.Colors.parchment)
                            .lineLimit(2)

                        Text(article.subtitle)
                            .font(GoldRushTheme.Typography.body(13))
                            .foregroundStyle(GoldRushTheme.Colors.ironGray)
                            .lineLimit(2)
                    }

                    Button(action: onBookmark) {
                        Image(systemName: article.isBookmarked ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(article.isBookmarked
                                             ? GoldRushTheme.Colors.richGold
                                             : GoldRushTheme.Colors.ironGray)
                            .font(.system(size: 18))
                    }
                    .buttonStyle(.plain)
                }
                .padding(GoldRushTheme.Spacing.md)
            }
        }
        .buttonStyle(.plain)
    }
}
