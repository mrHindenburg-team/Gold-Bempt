import Foundation

struct QuizSession: Identifiable {
    let id: UUID = UUID()
    let mode: QuizMode
    let topic: QuizTopic?
    var questions: [Question]
    var currentIndex: Int = 0
    var score: Int = 0
    var correctCount: Int = 0
    var streak: Int = 0
    var selectedAnswers: [Int: Int] = [:]
    var startTime: Date = .now
    var isFinished: Bool = false

    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    var isPerfect: Bool {
        correctCount == questions.count && !questions.isEmpty
    }

    mutating func answer(index: Int) -> Bool {
        guard let question = currentQuestion else { return false }
        selectedAnswers[currentIndex] = index
        let correct = index == question.correctIndex
        if correct {
            correctCount += 1
            streak += 1
            score += 10 * question.difficulty.pointMultiplier * max(1, streak / 3)
        } else {
            streak = 0
        }
        return correct
    }

    mutating func advance() {
        currentIndex += 1
        if mode != .survival && currentIndex >= questions.count {
            isFinished = true
        }
    }
}
