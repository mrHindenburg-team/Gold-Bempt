import Foundation

// FoundationModels is available on iOS 26+ devices with Apple Intelligence enabled.
// We guard the entire implementation behind @available so the rest of the app
// compiles against iOS 18.6 minimum while still benefitting from the model on
// supported hardware.

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26, *)
final class FoundationModelsService: AIServiceProtocol {

    private static let systemPrompt = """
    You are GoldRush Guide, an expert on the California Gold Rush (1848–1855) \
    and the broader North American gold rush era. Your answers are historically \
    accurate, engaging, and written at a reading level suitable for a curious \
    general audience. Keep responses concise (2–4 short paragraphs). \
    Focus only on Gold Rush history. Never invent facts. \
    If unsure, say so and offer what you do know.
    """

    private let session: LanguageModelSession

    var isAvailable: Bool { SystemLanguageModel.default.isAvailable }

    init() {
        session = LanguageModelSession(instructions: Self.systemPrompt)
    }

    func respond(to question: String, context: String) async throws -> String {
        guard isAvailable else { throw AIError.modelUnavailable }
        let prompt = context.isEmpty ? question : "\(question)\n\nContext: \(context)"
        let response = try await session.respond(to: prompt)
        return response.content
    }
}
#endif
