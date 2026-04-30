import Foundation

@Observable
final class QuizMenuViewModel {

    var selectedMode: QuizMode = .quick
    var selectedTopic: QuizTopic? = nil
    var showingQuiz = false
    var activeSession: QuizSession?

    private let quizUseCase: QuizUseCase

    init(quizUseCase: QuizUseCase) {
        self.quizUseCase = quizUseCase
    }

    func startQuiz() {
        let session = quizUseCase.startSession(mode: selectedMode, topic: selectedTopic)
        activeSession = session
        showingQuiz   = true
    }
}
