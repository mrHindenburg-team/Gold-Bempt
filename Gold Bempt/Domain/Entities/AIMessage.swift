import Foundation

enum AIMessageRole {
    case user
    case assistant
}

struct AIMessage: Identifiable {
    let id: UUID
    let role: AIMessageRole
    let content: String
    let timestamp: Date
    let isAIGenerated: Bool

    init(role: AIMessageRole, content: String, isAIGenerated: Bool = true) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = .now
        self.isAIGenerated = isAIGenerated
    }
}
