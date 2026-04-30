import SwiftUI

struct GoldButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    var isLoading = false

    enum ButtonStyle {
        case primary, secondary, danger
    }

    var body: some View {
        Button(action: action) {
            buttonLabel
        }
        .disabled(isLoading)
        .sensoryFeedback(.impact(weight: .medium), trigger: isLoading)
    }

    private var buttonLabel: some View {
        HStack(spacing: GoldRushTheme.Spacing.xs) {
            if isLoading {
                ProgressView()
                    .tint(labelColor)
                    .scaleEffect(0.8)
            }
            Text(title)
                .font(GoldRushTheme.Typography.heading(17))
                .foregroundStyle(labelColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, GoldRushTheme.Spacing.md)
        .padding(.horizontal, GoldRushTheme.Spacing.lg)
        .background(background)
        .clipShape(.rect(cornerRadius: GoldRushTheme.Radius.pill))
        .overlay {
            Capsule()
                .strokeBorder(borderColor, lineWidth: 1)
        }
    }

    private var labelColor: Color {
        switch style {
        case .primary:   GoldRushTheme.Colors.darkCharcoal
        case .secondary: GoldRushTheme.Colors.richGold
        case .danger:    GoldRushTheme.Colors.ashWhite
        }
    }

    private var background: some ShapeStyle {
        switch style {
        case .primary:   AnyShapeStyle(GoldRushTheme.Gradients.goldShimmer)
        case .secondary: AnyShapeStyle(Color.clear)
        case .danger:    AnyShapeStyle(GoldRushTheme.Gradients.survivalRed)
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary:   .clear
        case .secondary: GoldRushTheme.Colors.richGold.opacity(0.6)
        case .danger:    .clear
        }
    }
}

// MARK: - Icon Button

struct GoldIconButton: View {
    let iconName: String
    let label: String
    let action: () -> Void
    var isActive = false

    var body: some View {
        Button(label, systemImage: iconName, action: action)
            .font(GoldRushTheme.Typography.caption(12))
            .foregroundStyle(isActive ? GoldRushTheme.Colors.richGold : GoldRushTheme.Colors.ironGray)
            .sensoryFeedback(.selection, trigger: isActive)
    }
}
