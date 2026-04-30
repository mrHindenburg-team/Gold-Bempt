import Foundation

@Observable
final class LibraryViewModel {

    var allArticles: [Article] = []
    var filteredArticles: [Article] = []
    var selectedCategory: ArticleCategory? = nil
    var searchQuery = ""
    var isSearching = false

    private let libraryUseCase: LibraryUseCase
    private let progressUseCase: ProgressUseCase

    init(libraryUseCase: LibraryUseCase, progressUseCase: ProgressUseCase) {
        self.libraryUseCase  = libraryUseCase
        self.progressUseCase = progressUseCase
    }

    func load() {
        allArticles      = libraryUseCase.fetchAll()
        filteredArticles = allArticles
    }

    func applyFilter() {
        let base = selectedCategory.map { libraryUseCase.fetch(category: $0) } ?? allArticles
        if searchQuery.isEmpty {
            filteredArticles = base
        } else {
            filteredArticles = base.filter { $0.matches(query: searchQuery) }
        }
    }

    func toggleBookmark(for article: Article) {
        libraryUseCase.toggleBookmark(articleID: article.id)
        load()
    }

    func markRead(_ article: Article) {
        progressUseCase.markArticleRead(article.id)
    }

    func selectCategory(_ category: ArticleCategory?) {
        selectedCategory = category
        applyFilter()
    }
}
