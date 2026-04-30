import Foundation

final class QuizLocalDataSource {

    private let questions: [Question]

    init() {
        questions = Self.load()
    }

    func all() -> [Question] { questions }

    func byTopic(_ topic: QuizTopic) -> [Question] {
        questions.filter { $0.topic == topic }
    }

    func byDifficulty(_ difficulty: QuizDifficulty) -> [Question] {
        questions.filter { $0.difficulty == difficulty }
    }

    func random(count: Int) -> [Question] {
        Array(questions.shuffled().prefix(count))
    }

    func progressive(topic: QuizTopic?) -> [Question] {
        let pool = topic.map { byTopic($0) } ?? questions
        let easy   = pool.filter { $0.difficulty == .beginner     }.shuffled()
        let medium = pool.filter { $0.difficulty == .intermediate }.shuffled()
        let hard   = pool.filter { $0.difficulty == .expert       }.shuffled()
        let segment = 6
        return Array((easy.prefix(segment) + medium.prefix(segment) + hard.prefix(segment)).prefix(20))
    }

    // MARK: - Load

    private static func load() -> [Question] {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([QuestionDTO].self, from: data)
        else { return [] }
        return decoded.compactMap(\.toDomain)
    }
}

// MARK: - DTO

private struct QuestionDTO: Decodable {
    let id: String
    let text: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
    let topic: String
    let difficulty: String

    var toDomain: Question? {
        guard let uuid = UUID(uuidString: id),
              let topic = QuizTopic(rawValue: topic),
              let difficulty = QuizDifficulty(rawValue: difficulty)
        else { return nil }
        return Question(
            id: uuid,
            text: text,
            options: options,
            correctIndex: correctIndex,
            explanation: explanation,
            topic: topic,
            difficulty: difficulty
        )
    }
}
