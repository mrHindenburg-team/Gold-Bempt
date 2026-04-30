import Foundation

@Observable
final class ProgressUseCase {

    var progress: UserProgress
    var achievements: [Achievement]

    private let repository: ProgressRepositoryProtocol

    init(repository: ProgressRepositoryProtocol) {
        self.repository = repository
        self.progress   = repository.load()
        self.achievements = repository.loadAchievements()
    }

    func applyResult(session: QuizSession) {
        progress.totalQuestionsAnswered += session.questions.count
        progress.totalCorrectAnswers    += session.correctCount
        progress.totalPoints            += session.score
        progress.quizzesCompleted       += 1
        progress.currentStreak = max(progress.currentStreak, session.streak)
        progress.longestStreak = max(progress.longestStreak, session.streak)
        if let topic = session.topic {
            progress.topicsCompleted.insert(topic.rawValue)
            progress.topicCorrectAnswers[topic.rawValue, default: 0] += session.correctCount
        }
        var scores = progress.recentScores
        scores.append(session.score)
        progress.recentScores = Array(scores.suffix(7))
        checkAchievements(session: session)
        repository.save(progress)
    }

    func markArticleRead(_ id: UUID) {
        progress.articlesRead.insert(id)
        checkAchievement(AchievementID.bookworm, unlocked: progress.articlesRead.count >= 10)
        repository.save(progress)
    }

    func incrementAICount() {
        progress.aiQuestionsAsked       += 1
        progress.sessionAIQuestionsUsed += 1
        checkAchievement(AchievementID.aiApprentice, unlocked: progress.aiQuestionsAsked >= 5)
        repository.save(progress)
    }

    func resetSessionAICount() {
        progress.sessionAIQuestionsUsed = 0
        repository.save(progress)
    }

    func updatePlayerName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        progress.playerName = String(trimmed.prefix(30))
        repository.save(progress)
    }

    func updatePlayerIcon(_ iconName: String) {
        progress.playerIconName = iconName
        repository.save(progress)
    }

    // MARK: - Private

    private func checkAchievements(session: QuizSession) {
        checkAchievement(AchievementID.firstBlood,   unlocked: progress.totalCorrectAnswers >= 1)
        checkAchievement(AchievementID.hotStreak,    unlocked: progress.longestStreak >= 5)
        checkAchievement(AchievementID.goldMiner,    unlocked: progress.totalPoints >= 500)
        checkAchievement(AchievementID.historian,    unlocked: progress.topicsCompleted.count >= QuizTopic.allCases.count)
        checkAchievement(AchievementID.survivor,     unlocked: session.mode == .survival && session.currentIndex >= 20)
        checkAchievement(AchievementID.perfectRound, unlocked: session.isPerfect)
    }

    private func checkAchievement(_ id: String, unlocked: Bool) {
        guard unlocked, !(achievements.first { $0.id == id }?.isUnlocked ?? false) else { return }
        repository.unlock(achievementID: id)
        if let idx = achievements.firstIndex(where: { $0.id == id }) {
            achievements[idx].isUnlocked = true
            achievements[idx].unlockedDate = .now
        }
    }
}
