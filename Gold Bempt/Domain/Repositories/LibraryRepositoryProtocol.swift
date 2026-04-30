import Foundation

protocol LibraryRepositoryProtocol {
    func fetchAll() -> [Article]
    func fetch(category: ArticleCategory) -> [Article]
    func search(query: String) -> [Article]
    func fetchBookmarked() -> [Article]
    func toggleBookmark(articleID: UUID)
}
