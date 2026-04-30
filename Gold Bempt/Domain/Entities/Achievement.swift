import Foundation

struct Achievement: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    var isUnlocked: Bool
    var unlockedDate: Date?
}

enum AchievementID {
    static let firstBlood    = "first_correct"
    static let hotStreak     = "streak_5"
    static let goldMiner     = "score_500"
    static let historian     = "all_topics"
    static let survivor      = "survival_20"
    static let bookworm      = "read_10_articles"
    static let aiApprentice  = "ai_5_questions"
    static let perfectRound  = "perfect_quiz"

    static var all: [Achievement] {
        [
            Achievement(id: firstBlood,   title: "First Strike",     description: "Answer your first question correctly.",  iconName: "star.fill",            isUnlocked: false),
            Achievement(id: hotStreak,    title: "Hot Streak",       description: "Get 5 answers correct in a row.",       iconName: "flame.fill",           isUnlocked: false),
            Achievement(id: goldMiner,    title: "Gold Miner",       description: "Earn 500 total points.",                 iconName: "circle.fill",          isUnlocked: false),
            Achievement(id: historian,    title: "True Historian",   description: "Complete a quiz in every topic.",       iconName: "book.fill",            isUnlocked: false),
            Achievement(id: survivor,     title: "Iron Will",        description: "Survive 20 questions in Survival mode.", iconName: "shield.fill",          isUnlocked: false),
            Achievement(id: bookworm,     title: "Bookworm",         description: "Read 10 library articles.",             iconName: "books.vertical.fill",  isUnlocked: false),
            Achievement(id: aiApprentice, title: "AI Apprentice",    description: "Ask the AI assistant 5 questions.",     iconName: "sparkles",             isUnlocked: false),
            Achievement(id: perfectRound, title: "Perfect Round",    description: "Complete a quiz without a single error.", iconName: "checkmark.seal.fill", isUnlocked: false),
        ]
    }
}
