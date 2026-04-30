import Foundation

struct Article: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let category: ArticleCategory
    let body: String
    let tags: [String]
    let readTimeMinutes: Int
    let yearContext: String
    var isBookmarked: Bool = false

    func matches(query: String) -> Bool {
        guard !query.isEmpty else { return true }
        return title.localizedStandardContains(query)
            || subtitle.localizedStandardContains(query)
            || body.localizedStandardContains(query)
            || tags.contains { $0.localizedStandardContains(query) }
    }
}
