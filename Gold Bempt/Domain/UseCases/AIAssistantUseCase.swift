import Foundation

private let freeSessionLimit = 5

@Observable
final class AIAssistantUseCase {

    var messages: [AIMessage] = []
    var isThinking = false
    var sessionQueriesUsed = 0

    var isAIAvailable: Bool { primaryService.isAvailable }
    var isAtFreeLimit: Bool { !storeKit.hasExplorerPack && sessionQueriesUsed >= freeSessionLimit }

    private let primaryService: AIServiceProtocol
    private let fallbackService: AIServiceProtocol
    private let progressUseCase: ProgressUseCase
    private let storeKit: StoreKitService

    init(progressUseCase: ProgressUseCase, storeKit: StoreKitService) {
        self.progressUseCase = progressUseCase
        self.storeKit        = storeKit
        self.fallbackService = FallbackAIService()
        #if canImport(FoundationModels)
        if #available(iOS 26, *) {
            let fm = FoundationModelsService()
            self.primaryService = fm.isAvailable ? fm : fallbackService
        } else {
            self.primaryService = fallbackService
        }
        #else
        self.primaryService = fallbackService
        #endif
    }

    func send(question: String, context: String = "") async {
        let userMsg = AIMessage(role: .user, content: question, isAIGenerated: false)
        messages.append(userMsg)
        isThinking = true
        defer { isThinking = false }

        do {
            let service: AIServiceProtocol
            let isGenerated: Bool
            if isAtFreeLimit || !primaryService.isAvailable {
                service = fallbackService
                isGenerated = false
            } else {
                service = primaryService
                isGenerated = true
                sessionQueriesUsed += 1
                progressUseCase.incrementAICount()
            }
            let answer = try await service.respond(to: question, context: context)
            let response = AIMessage(role: .assistant, content: answer, isAIGenerated: isGenerated)
            messages.append(response)
        } catch {
            let fallback = AIMessage(
                role: .assistant,
                content: "I couldn't find a detailed answer right now. Try rephrasing your question about the Gold Rush.",
                isAIGenerated: false
            )
            messages.append(fallback)
        }
    }

    func clearHistory() {
        messages = []
    }
}
