import SwiftUI

struct ContentView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator
        TabView(selection: $coordinator.selectedTab) {
            Tab("Home", systemImage: "house.fill", value: AppTab.home) {
                HomeView()
            }
            Tab("Quizzes", systemImage: "bolt.fill", value: AppTab.quiz) {
                QuizMenuView()
            }
            Tab("Library", systemImage: "books.vertical.fill", value: AppTab.library) {
                LibraryView()
            }
            Tab("AI Guide", systemImage: "sparkles", value: AppTab.assistant) {
                AssistantView()
            }
            Tab("Profile", systemImage: "person.fill", value: AppTab.profile) {
                ProfileView()
            }
        }
        .tint(GoldRushTheme.Colors.richGold)
    }
}
