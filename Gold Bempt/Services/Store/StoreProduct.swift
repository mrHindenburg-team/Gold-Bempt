import Foundation

enum StoreProduct: String, CaseIterable, Identifiable {
    case explorerPack  = "com.goldrush.explorerpack"
    case historianPack = "com.goldrush.historianpack"

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .explorerPack:  "Explorer Pack"
        case .historianPack: "Historian Pack"
        }
    }

    var tagline: String {
        switch self {
        case .explorerPack:  "Remove the AI query limit forever"
        case .historianPack: "Unlock full articles and bookmarks"
        }
    }

    var features: [String] {
        switch self {
        case .explorerPack:
            [
                "Unlimited AI Guide queries per session",
                "Removes the 5-query free limit",
                "All AI responses powered by on-device model",
            ]
        case .historianPack:
            [
                "Read full text of every historical article",
                "Free users see a short preview only",
                "Save unlimited bookmarks",
            ]
        }
    }

    var iconName: String {
        switch self {
        case .explorerPack:  "sparkles"
        case .historianPack: "books.vertical.fill"
        }
    }
}
