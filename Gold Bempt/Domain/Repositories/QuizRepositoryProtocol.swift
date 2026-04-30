import Foundation

protocol QuizRepositoryProtocol {
    func fetchAll() -> [Question]
    func fetch(topic: QuizTopic, difficulty: QuizDifficulty?) -> [Question]
    func fetchRandom(count: Int) -> [Question]
    func fetchProgressive(topic: QuizTopic?) -> [Question]
}
