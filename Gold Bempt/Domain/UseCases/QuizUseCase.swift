import Foundation

final class QuizUseCase {

    private let repository: QuizRepositoryProtocol

    init(repository: QuizRepositoryProtocol) {
        self.repository = repository
    }

    func startSession(mode: QuizMode, topic: QuizTopic? = nil) -> QuizSession {
        let questions: [Question]
        switch mode {
        case .quick:
            questions = repository.fetchRandom(count: 10)
        case .topicBased:
            let t = topic ?? QuizTopic.allCases.randomElement()!
            questions = repository.fetch(topic: t, difficulty: nil)
                .shuffled()
                .prefix(15)
                .map { $0 }
        case .progressive:
            questions = repository.fetchProgressive(topic: topic)
        case .survival:
            questions = repository.fetchAll().shuffled()
        }
        return QuizSession(mode: mode, topic: topic, questions: questions)
    }
}
