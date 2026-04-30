import Foundation
import Speech
import AVFoundation

enum SpeechRecognitionState: Equatable {
    case idle
    case listening
    case processing
    case done(String)
    case failed(String)
}

@Observable
final class SpeechRecognitionService {

    var state: SpeechRecognitionState = .idle
    var isAuthorized = false

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let confidenceThreshold: Float = 0.5

    func requestAuthorization() async {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0) }
        }
        isAuthorized = (status == .authorized)
    }

    func startListening() {
        guard isAuthorized, recognizer?.isAvailable == true else {
            state = .failed("Speech recognition not available.")
            return
        }
        guard !audioEngine.isRunning else { return }
        do {
            try beginSession()
            state = .listening
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func stopListening() {
        guard audioEngine.isRunning else { return }
        audioEngine.stop()
        recognitionRequest?.endAudio()
        state = .processing
    }

    func reset() {
        cancelSession()
        state = .idle
    }

    // MARK: - Private

    private func beginSession() throws {
        cancelSession()
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        #endif

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else { return }
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = true

        let node = audioEngine.inputNode
        let format = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            if let result {
                let transcript = result.bestTranscription.formattedString
                if result.isFinal {
                    self.state = .done(transcript)
                    self.cancelSession()
                }
            } else if let error {
                self.state = .failed(error.localizedDescription)
                self.cancelSession()
            }
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    private func cancelSession() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
    }
}
