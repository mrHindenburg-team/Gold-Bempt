import Foundation

struct OnboardingSlide: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let body: String
    let iconName: String
    let accentColor: String
}

@Observable
final class OnboardingViewModel {

    var currentPage = 0
    let slides: [OnboardingSlide] = [
        OnboardingSlide(
            id: 0,
            title: "Discover History",
            subtitle: "1848 — The Year That Changed Everything",
            body: "Explore the untold stories, key events, and legendary figures of the California Gold Rush. From Sutter's Mill to San Francisco's transformation, every page brings the past to life.",
            iconName: "map.fill",
            accentColor: "gold"
        ),
        OnboardingSlide(
            id: 1,
            title: "Test Your Knowledge",
            subtitle: "Four Ways to Play",
            body: "Quick quizzes, topic challenges, progressive difficulty, and survival mode. Over 50 hand-crafted questions covering events, figures, locations, economics, and the myths that shaped the era.",
            iconName: "questionmark.diamond.fill",
            accentColor: "orange"
        ),
        OnboardingSlide(
            id: 2,
            title: "Explore the Library",
            subtitle: "20+ Rich Historical Articles",
            body: "Deep-dive biographies, timeline guides, economic analyses, and society portraits — all stored locally on your device. No internet required. Browse, search, and bookmark your favorites.",
            iconName: "books.vertical.fill",
            accentColor: "brown"
        ),
        OnboardingSlide(
            id: 3,
            title: "AI History Guide",
            subtitle: "Powered by Apple Intelligence",
            body: "Ask anything about the Gold Rush in plain language. Your on-device AI guide answers questions, expands on quiz results, and simplifies complex history — completely offline and private.",
            iconName: "sparkles",
            accentColor: "purple"
        ),
    ]

    var isLastSlide: Bool { currentPage == slides.count - 1 }

    func advance() {
        guard !isLastSlide else { return }
        currentPage += 1
    }

    func skip() {
        currentPage = slides.count - 1
    }
}
