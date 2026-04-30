import Foundation
import Speech

@Observable
final class AssistantViewModel {

    var inputText = ""
    var isVoiceActive = false

    private let assistantUseCase: AIAssistantUseCase
    private let speechService: SpeechRecognitionService
    private let storeKit: StoreKitService

    var messages: [AIMessage] { assistantUseCase.messages }
    var isThinking: Bool { assistantUseCase.isThinking }
    var isAtFreeLimit: Bool { assistantUseCase.isAtFreeLimit }
    var sessionQueriesUsed: Int { assistantUseCase.sessionQueriesUsed }

    init(assistantUseCase: AIAssistantUseCase, speechService: SpeechRecognitionService, storeKit: StoreKitService) {
        self.assistantUseCase = assistantUseCase
        self.speechService    = speechService
        self.storeKit         = storeKit
    }

    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        inputText = ""
        await assistantUseCase.send(question: text)
    }

    func sendLimitedResponse() async {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        inputText = ""
        await assistantUseCase.send(question: text, context: "free-tier")
    }

    func clearHistory() {
        assistantUseCase.clearHistory()
    }

    func requestSpeechPermission() async {
        await speechService.requestAuthorization()
    }

    func toggleVoice() {
        if isVoiceActive {
            speechService.stopListening()
            isVoiceActive = false
        } else {
            speechService.startListening()
            isVoiceActive = true
        }
    }

    func handleSpeechState(_ state: SpeechRecognitionState) {
        switch state {
        case .done(let transcript):
            inputText = transcript
            isVoiceActive = false
        case .failed:
            isVoiceActive = false
        default:
            break
        }
    }
}
