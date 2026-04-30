import Foundation

final class QuizRepository: QuizRepositoryProtocol {

    private let dataSource: QuizLocalDataSource

    init(dataSource: QuizLocalDataSource = QuizLocalDataSource()) {
        self.dataSource = dataSource
    }

    func fetchAll() -> [Question] {
        dataSource.all()
    }

    func fetch(topic: QuizTopic, difficulty: QuizDifficulty?) -> [Question] {
        var questions = dataSource.byTopic(topic)
        if let difficulty {
            questions = questions.filter { $0.difficulty == difficulty }
        }
        return questions.shuffled()
    }

    func fetchRandom(count: Int) -> [Question] {
        dataSource.random(count: count)
    }

    func fetchProgressive(topic: QuizTopic?) -> [Question] {
        dataSource.progressive(topic: topic)
    }
}
