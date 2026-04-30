import Foundation

enum QuizMode: String, CaseIterable, Identifiable {
    case quick       = "Quick Quiz"
    case topicBased  = "Topic Challenge"
    case progressive = "Progressive"
    case survival    = "Survival"

    var id: String { rawValue }

    var questionCount: Int {
        switch self {
        case .quick:       10
        case .topicBased:  15
        case .progressive: 20
        case .survival:    .max
        }
    }

    var description: String {
        switch self {
        case .quick:
            "10 random questions across all topics. Fast and fun."
        case .topicBased:
            "15 questions focused on a single topic of your choice."
        case .progressive:
            "20 questions that increase in difficulty as you go."
        case .survival:
            "Answer until you fail. How far can you go?"
        }
    }

    var iconName: String {
        switch self {
        case .quick:       "bolt.fill"
        case .topicBased:  "book.fill"
        case .progressive: "chart.line.uptrend.xyaxis"
        case .survival:    "flame.fill"
        }
    }

    var isTimed: Bool {
        self == .survival || self == .progressive
    }
}
