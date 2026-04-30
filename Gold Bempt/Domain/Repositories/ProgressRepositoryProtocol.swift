import Foundation

protocol ProgressRepositoryProtocol {
    func load() -> UserProgress
    func save(_ progress: UserProgress)
    func loadAchievements() -> [Achievement]
    func unlock(achievementID: String)
}
