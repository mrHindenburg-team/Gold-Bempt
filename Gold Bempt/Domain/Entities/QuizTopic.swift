import Foundation

enum QuizTopic: String, Codable, CaseIterable, Identifiable {
    case events     = "Key Events"
    case figures    = "Historical Figures"
    case locations  = "Locations"
    case dailyLife  = "Daily Life"
    case economics  = "Economics"
    case myths      = "Myths & Legends"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .events:    "calendar.badge.clock"
        case .figures:   "person.bust"
        case .locations: "map"
        case .dailyLife: "house"
        case .economics: "banknote"
        case .myths:     "sparkles"
        }
    }

    var description: String {
        switch self {
        case .events:    "Pivotal moments that shaped the Gold Rush era"
        case .figures:   "The prospectors, merchants, and leaders of the age"
        case .locations: "The rivers, camps, and cities that defined the rush"
        case .dailyLife: "How miners, families, and settlers actually lived"
        case .economics: "Gold markets, fortunes made, and supply chains"
        case .myths:     "Tall tales, legends, and fictions of the era"
        }
    }
}
