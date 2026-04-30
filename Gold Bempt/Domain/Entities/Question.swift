import Foundation

struct Question: Identifiable, Codable, Hashable {
    let id: UUID
    let text: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
    let topic: QuizTopic
    let difficulty: QuizDifficulty

    var correctAnswer: String { options[correctIndex] }
}
