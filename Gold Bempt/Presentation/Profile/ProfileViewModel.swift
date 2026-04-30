import Foundation

@Observable
final class ProfileViewModel {

    var progress: UserProgress = UserProgress()
    var achievements: [Achievement] = []
    var isEditingName = false

    private let progressUseCase: ProgressUseCase

    init(progressUseCase: ProgressUseCase) {
        self.progressUseCase = progressUseCase
    }

    func load() {
        progress     = progressUseCase.progress
        achievements = progressUseCase.achievements
    }

    var unlockedAchievements: [Achievement] { achievements.filter(\.isUnlocked) }
    var lockedAchievements:   [Achievement] { achievements.filter { !$0.isUnlocked } }

    func updateName(_ name: String) {
        progressUseCase.updatePlayerName(name)
        progress = progressUseCase.progress
    }

    func updateIcon(_ iconName: String) {
        progressUseCase.updatePlayerIcon(iconName)
        progress = progressUseCase.progress
    }
}
