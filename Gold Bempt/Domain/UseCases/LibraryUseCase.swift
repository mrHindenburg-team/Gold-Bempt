import Foundation

final class LibraryUseCase {

    private let repository: LibraryRepositoryProtocol

    init(repository: LibraryRepositoryProtocol) {
        self.repository = repository
    }

    func fetchAll() -> [Article] {
        repository.fetchAll()
    }

    func fetch(category: ArticleCategory) -> [Article] {
        repository.fetch(category: category)
    }

    func search(query: String) -> [Article] {
        repository.search(query: query)
    }

    func bookmarked() -> [Article] {
        repository.fetchBookmarked()
    }

    func toggleBookmark(articleID: UUID) {
        repository.toggleBookmark(articleID: articleID)
    }
}
