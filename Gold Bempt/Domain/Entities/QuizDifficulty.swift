import Foundation

enum QuizDifficulty: String, Codable, CaseIterable, Identifiable {
    case beginner     = "Beginner"
    case intermediate = "Intermediate"
    case expert       = "Expert"

    var id: String { rawValue }

    var pointMultiplier: Int {
        switch self {
        case .beginner:     1
        case .intermediate: 2
        case .expert:       3
        }
    }

    var timeLimit: TimeInterval {
        switch self {
        case .beginner:     30
        case .intermediate: 20
        case .expert:       12
        }
    }
}
