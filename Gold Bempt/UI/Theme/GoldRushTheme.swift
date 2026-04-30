import SwiftUI

enum GoldRushTheme {

    // MARK: - Colors

    enum Colors {
        static let deepBrown        = Color(red: 0.24, green: 0.17, blue: 0.12)
        static let richGold         = Color(red: 0.83, green: 0.63, blue: 0.09)
        static let brightGold       = Color(red: 0.91, green: 0.79, blue: 0.42)
        static let mutedOrange      = Color(red: 0.79, green: 0.49, blue: 0.31)
        static let darkCharcoal     = Color(red: 0.10, green: 0.10, blue: 0.18)
        static let parchment        = Color(red: 0.96, green: 0.90, blue: 0.78)
        static let parchmentDark    = Color(red: 0.88, green: 0.79, blue: 0.62)
        static let dustyYellow      = Color(red: 0.91, green: 0.79, blue: 0.42)
        static let mossGreen        = Color(red: 0.18, green: 0.35, blue: 0.15)
        static let crimsonRed       = Color(red: 0.55, green: 0.10, blue: 0.10)
        static let ironGray         = Color(red: 0.35, green: 0.33, blue: 0.30)
        static let ashWhite         = Color(red: 0.93, green: 0.91, blue: 0.87)
    }

    // MARK: - Gradients

    enum Gradients {
        static let goldShimmer = LinearGradient(
            colors: [Colors.richGold, Colors.brightGold, Colors.mutedOrange, Colors.richGold],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let darkBackground = LinearGradient(
            colors: [Colors.darkCharcoal, Color(red: 0.14, green: 0.11, blue: 0.08)],
            startPoint: .top,
            endPoint: .bottom
        )
        static let parchmentBackground = LinearGradient(
            colors: [Colors.parchment, Colors.parchmentDark],
            startPoint: .top,
            endPoint: .bottom
        )
        static let survivalRed = LinearGradient(
            colors: [Colors.crimsonRed, Color(red: 0.35, green: 0.06, blue: 0.06)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let cardDepth = LinearGradient(
            colors: [
                Colors.deepBrown.opacity(0.85),
                Colors.deepBrown.opacity(0.60)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        static let heroOverlay = LinearGradient(
            colors: [.clear, Colors.darkCharcoal.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Typography

    enum Typography {
        static func display(_ size: Double) -> Font {
            .system(size: size, weight: .black, design: .serif)
        }
        static func heading(_ size: Double) -> Font {
            .system(size: size, weight: .bold, design: .serif)
        }
        static func body(_ size: Double = 16) -> Font {
            .system(size: size, weight: .regular, design: .serif)
        }
        static func caption(_ size: Double = 13) -> Font {
            .system(size: size, weight: .medium, design: .serif)
        }
        static func mono(_ size: Double = 14) -> Font {
            .system(size: size, weight: .medium, design: .monospaced)
        }
    }

    // MARK: - Spacing

    enum Spacing {
        static let xxs:  Double = 4
        static let xs:   Double = 8
        static let sm:   Double = 12
        static let md:   Double = 16
        static let lg:   Double = 24
        static let xl:   Double = 32
        static let xxl:  Double = 48
        static let xxxl: Double = 64
    }

    // MARK: - Corner Radii

    enum Radius {
        static let sm:  Double = 8
        static let md:  Double = 14
        static let lg:  Double = 20
        static let xl:  Double = 28
        static let pill: Double = 100
    }

    // MARK: - Shadows

    static func cardShadow(color: Color = Colors.deepBrown) -> some View {
        Color.clear
            .shadow(color: color.opacity(0.5), radius: 12, x: 0, y: 6)
    }
}
