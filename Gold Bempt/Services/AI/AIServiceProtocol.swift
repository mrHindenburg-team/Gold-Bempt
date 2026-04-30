import Foundation

protocol AIServiceProtocol: Sendable {
    var isAvailable: Bool { get }
    func respond(to question: String, context: String) async throws -> String
}

enum AIError: Error, LocalizedError {
    case modelUnavailable
    case sessionFailed(String)
    case rateLimitReached

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:  "On-device AI is not available on this device."
        case .sessionFailed(let msg): "AI session error: \(msg)"
        case .rateLimitReached:  "Daily AI question limit reached."
        }
    }
}
