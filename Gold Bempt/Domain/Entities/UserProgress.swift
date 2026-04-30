import Foundation

struct UserProgress: Codable {
    var totalPoints: Int = 0
    var totalQuestionsAnswered: Int = 0
    var totalCorrectAnswers: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var topicsCompleted: Set<String> = []
    var articlesRead: Set<UUID> = []
    var achievements: [String: Bool] = [:]
    var quizzesCompleted: Int = 0
    var aiQuestionsAsked: Int = 0
    var sessionAIQuestionsUsed: Int = 0
    var lastResetDate: Date = .now
    var playerName: String = "Prospector"
    var playerIconName: String = "star.fill"
    var recentScores: [Int] = []
    var topicCorrectAnswers: [String: Int] = [:]

    var accuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalQuestionsAnswered)
    }

    var accuracyPercent: Int { Int(accuracy * 100) }
}
