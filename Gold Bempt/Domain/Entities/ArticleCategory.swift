import Foundation

enum ArticleCategory: String, Codable, CaseIterable, Identifiable {
    case timeline   = "Timeline"
    case biography  = "Biography"
    case location   = "Locations"
    case economy    = "Economy"
    case society    = "Society"
    case technology = "Technology"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .timeline:   "clock.arrow.circlepath"
        case .biography:  "person.text.rectangle"
        case .location:   "location.fill"
        case .economy:    "chart.bar.fill"
        case .society:    "person.3.fill"
        case .technology: "wrench.and.screwdriver.fill"
        }
    }
}
