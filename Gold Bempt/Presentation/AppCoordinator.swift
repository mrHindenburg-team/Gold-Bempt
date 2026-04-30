import SwiftUI

enum AppTab {
    case home, quiz, library, assistant, profile
}

@Observable
final class AppCoordinator {

    // MARK: - Navigation State

    var selectedTab: AppTab = .home
    var showSplash = true
    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "onboardingDone") }
    }

    // MARK: - Services & Use Cases (owned here, shared via environment)

    let storeKit       = StoreKitService()
    let progressUseCase: ProgressUseCase
    let quizUseCase:     QuizUseCase
    let libraryUseCase:  LibraryUseCase
    let assistantUseCase: AIAssistantUseCase
    let speechService  = SpeechRecognitionService()

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "onboardingDone")

        let progressRepo = ProgressRepository()
        let quizRepo     = QuizRepository()
        let libraryRepo  = LibraryRepository()

        progressUseCase  = ProgressUseCase(repository: progressRepo)
        quizUseCase      = QuizUseCase(repository: quizRepo)
        libraryUseCase   = LibraryUseCase(repository: libraryRepo)
        assistantUseCase = AIAssistantUseCase(
            progressUseCase: progressUseCase,
            storeKit: storeKit
        )
    }

    func completeSplash() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showSplash = false
        }
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    func navigateTo(_ tab: AppTab) {
        selectedTab = tab
    }
}
