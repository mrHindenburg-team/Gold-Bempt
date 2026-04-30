import SwiftUI

@main
struct Gold_BemptApp: App {
    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            rootView
                .environment(coordinator)
        }
    }

    @ViewBuilder
    private var rootView: some View {
        if coordinator.showSplash {
            SplashView()
        } else if !coordinator.hasCompletedOnboarding {
            OnboardingView()
        } else {
            ContentView()
        }
    }
}
