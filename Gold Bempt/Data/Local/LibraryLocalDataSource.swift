import Foundation

final class LibraryLocalDataSource {

    private var articles: [Article]

    init() {
        articles = Self.load()
    }

    func all() -> [Article] { articles }

    func byCategory(_ category: ArticleCategory) -> [Article] {
        articles.filter { $0.category == category }
    }

    func search(query: String) -> [Article] {
        guard !query.isEmpty else { return articles }
        return articles.filter { $0.matches(query: query) }
    }

    func bookmarked() -> [Article] {
        articles.filter(\.isBookmarked)
    }

    func toggleBookmark(articleID: UUID) {
        if let idx = articles.firstIndex(where: { $0.id == articleID }) {
            articles[idx].isBookmarked.toggle()
        }
    }

    // MARK: - Load

    private static func load() -> [Article] {
        guard let url = Bundle.main.url(forResource: "articles", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([ArticleDTO].self, from: data)
        else { return [] }
        return decoded.compactMap(\.toDomain)
    }
}

// MARK: - DTO

private struct ArticleDTO: Decodable {
    let id: String
    let title: String
    let subtitle: String
    let category: String
    let body: String
    let tags: [String]
    let readTimeMinutes: Int
    let yearContext: String

    var toDomain: Article? {
        guard let uuid = UUID(uuidString: id),
              let category = ArticleCategory(rawValue: category)
        else { return nil }
        return Article(
            id: uuid,
            title: title,
            subtitle: subtitle,
            category: category,
            body: body,
            tags: tags,
            readTimeMinutes: readTimeMinutes,
            yearContext: yearContext
        )
    }
}
