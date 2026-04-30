import Foundation

@Observable
final class HomeViewModel {

    var featuredArticle: Article?
    var recentArticles: [Article] = []
    var dailyFact: String = ""
    var recentAccuracy: Double = 0
    var recentPoints: Int = 0
    var totalStreak: Int = 0
    var quizzesCompleted: Int = 0
    var topicProgress: [(topic: QuizTopic, isCompleted: Bool)] = []
    var recentScores: [Int] = []
    var topicMastery: [(topic: QuizTopic, fraction: Double)] = []

    private let libraryUseCase: LibraryUseCase
    private let progressUseCase: ProgressUseCase

    private static let seedFacts = [
        "Gold is so dense that a cubic foot of it weighs over half a ton.",
        "James Marshall, who discovered gold at Sutter's Mill, died penniless in 1885.",
        "San Francisco's population jumped from 1,000 to 25,000 in just two years.",
        "Sam Brannan became California's first millionaire by selling supplies, not mining gold.",
        "Women made up fewer than 8% of California's Gold Rush population.",
        "Levi Strauss's famous riveted denim pants were patented in 1873.",
        "Over 300,000 people migrated to California between 1848 and 1855.",
        "Fool's gold (iron pyrite) is 7 times lighter than real gold.",
        "The phrase 'pan out' originated in Gold Rush placer mining.",
        "California's state motto 'Eureka' means 'I have found it' in Greek.",
    ]

    init(libraryUseCase: LibraryUseCase, progressUseCase: ProgressUseCase) {
        self.libraryUseCase  = libraryUseCase
        self.progressUseCase = progressUseCase
    }

    func load() {
        let articles = libraryUseCase.fetchAll()
        featuredArticle = articles.first
        recentArticles  = Array(articles.prefix(6))
        dailyFact       = Self.seedFacts.randomElement() ?? ""

        let progress = progressUseCase.progress
        recentAccuracy   = progress.accuracy
        recentPoints     = progress.totalPoints
        totalStreak      = progress.longestStreak
        quizzesCompleted = progress.quizzesCompleted

        topicProgress = QuizTopic.allCases.map { topic in
            (topic: topic, isCompleted: progress.topicsCompleted.contains(topic.rawValue))
        }
        recentScores = progress.recentScores
        topicMastery = QuizTopic.allCases.map { topic in
            let correct = progress.topicCorrectAnswers[topic.rawValue] ?? 0
            return (topic: topic, fraction: min(Double(correct) / 10.0, 1.0))
        }
    }
}
