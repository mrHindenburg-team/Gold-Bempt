import SwiftUI

@Observable
final class QuizViewModel {

    var session: QuizSession
    var selectedAnswerIndex: Int? = nil
    var answerState: AnswerState = .unanswered
    var timeRemaining: Double = 30
    var timerProgress: Double = 1.0
    var showExplanation = false
    var isFinished = false

    enum AnswerState: Equatable {
        case unanswered
        case correct
        case incorrect(correct: Int)
    }

    private let progressUseCase: ProgressUseCase
    private var timerTask: Task<Void, Never>?

    init(session: QuizSession, progressUseCase: ProgressUseCase) {
        self.session      = session
        self.progressUseCase = progressUseCase
        if session.mode.isTimed {
            startTimer()
        }
    }

    var currentQuestion: Question? { session.currentQuestion }
    var progress: Double { session.progress }
    var score: Int { session.score }
    var streak: Int { session.streak }
    var totalCount: Int { session.questions.count }
    var currentIndex: Int { session.currentIndex }

    func select(answerIndex: Int) {
        guard answerState == .unanswered, !isFinished else { return }
        timerTask?.cancel()
        selectedAnswerIndex = answerIndex
        let correct = session.answer(index: answerIndex)
        answerState = correct
            ? .correct
            : .incorrect(correct: session.currentQuestion?.correctIndex ?? answerIndex)
    }

    func advance() {
        session.advance()
        selectedAnswerIndex = nil
        answerState  = .unanswered
        showExplanation = false

        if session.isFinished || (session.mode == .survival && currentQuestion == nil) {
            finish()
            return
        }

        if session.mode.isTimed {
            let limit = currentQuestion?.difficulty.timeLimit ?? 30
            timeRemaining = limit
            timerProgress = 1.0
            startTimer()
        }
    }

    func revealExplanation() {
        showExplanation = true
    }

    func finish() {
        timerTask?.cancel()
        isFinished = true
        progressUseCase.applyResult(session: session)
    }

    // MARK: - Timer

    private func startTimer() {
        let limit = currentQuestion?.difficulty.timeLimit ?? 30
        timeRemaining = limit
        timerProgress = 1.0
        timerTask?.cancel()
        timerTask = Task {
            let interval = 0.1
            while timeRemaining > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                timeRemaining = max(0, timeRemaining - interval)
                timerProgress = timeRemaining / limit
            }
            if timeRemaining <= 0 && answerState == .unanswered {
                select(answerIndex: -1)
            }
        }
    }
}
