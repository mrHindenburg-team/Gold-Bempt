import Foundation

final class ProgressRepository: ProgressRepositoryProtocol {

    private let progressKey    = "user_progress_v1"
    private let achievementsKey = "user_achievements_v1"

    func load() -> UserProgress {
        guard let data = UserDefaults.standard.data(forKey: progressKey),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data)
        else { return UserProgress() }
        return progress
    }

    func save(_ progress: UserProgress) {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: progressKey)
    }

    func loadAchievements() -> [Achievement] {
        guard let data = UserDefaults.standard.data(forKey: achievementsKey),
              let saved = try? JSONDecoder().decode([String: Bool].self, from: data)
        else { return AchievementID.all }
        return AchievementID.all.map { achievement in
            var a = achievement
            a.isUnlocked = saved[achievement.id] ?? false
            return a
        }
    }

    func unlock(achievementID: String) {
        var current = loadAchievements().reduce(into: [String: Bool]()) {
            $0[$1.id] = $1.isUnlocked
        }
        current[achievementID] = true
        guard let data = try? JSONEncoder().encode(current) else { return }
        UserDefaults.standard.set(data, forKey: achievementsKey)
    }
}
