import Foundation

final class LibraryRepository: LibraryRepositoryProtocol {

    private let dataSource: LibraryLocalDataSource

    init(dataSource: LibraryLocalDataSource = LibraryLocalDataSource()) {
        self.dataSource = dataSource
    }

    func fetchAll() -> [Article] {
        dataSource.all()
    }

    func fetch(category: ArticleCategory) -> [Article] {
        dataSource.byCategory(category)
    }

    func search(query: String) -> [Article] {
        dataSource.search(query: query)
    }

    func fetchBookmarked() -> [Article] {
        dataSource.bookmarked()
    }

    func toggleBookmark(articleID: UUID) {
        dataSource.toggleBookmark(articleID: articleID)
    }
}
