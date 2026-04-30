import SwiftUI
import StoreKit

struct StoreView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: StoreViewModel?
    @State private var showErrorAlert = false
    @State private var showSuccessAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                GoldRushTheme.Gradients.darkBackground
                    .ignoresSafeArea()

                if let vm = viewModel {
                    storeContent(vm: vm)
                } else {
                    ProgressView().tint(GoldRushTheme.Colors.richGold)
                }
            }
            .navigationTitle("Unlock More")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(GoldRushTheme.Colors.darkCharcoal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done", action: dismiss.callAsFunction)
                        .foregroundStyle(GoldRushTheme.Colors.richGold)
                }
            }
        }
        .task {
            let vm = StoreViewModel(storeKit: coordinator.storeKit)
            viewModel = vm
            await vm.load()
        }
        .onChange(of: viewModel?.errorMessage) { showErrorAlert = viewModel?.errorMessage != nil }
        .onChange(of: viewModel?.successMessage) { showSuccessAlert = viewModel?.successMessage != nil }
        .alert("Purchase Error",
               isPresented: $showErrorAlert,
               presenting: viewModel?.errorMessage) { _ in } message: { msg in
            Text(msg)
        }
        .alert("Purchase Complete",
               isPresented: $showSuccessAlert,
               presenting: viewModel?.successMessage) { _ in } message: { msg in
            Text(msg)
        }
    }

    private func storeContent(vm: StoreViewModel) -> some View {
        ScrollView {
            VStack(spacing: GoldRushTheme.Spacing.lg) {
                storeHeader
                    .padding(.top, GoldRushTheme.Spacing.lg)

                ForEach(StoreProduct.allCases) { product in
                    ProductCard(
                        product: product,
                        isPurchased: vm.isPurchased(product),
                        isPurchasing: vm.isPurchasing,
                        onPurchase: { Task { await vm.purchase(product) } }
                    )
                }
                .padding(.horizontal, GoldRushTheme.Spacing.md)

                restoreButton(vm: vm)
                    .padding(.horizontal, GoldRushTheme.Spacing.md)

                legalText
                    .padding(.horizontal, GoldRushTheme.Spacing.md)
                    .padding(.bottom, GoldRushTheme.Spacing.xxl)
            }
        }
        .scrollIndicators(.hidden)
    }

    private var storeHeader: some View {
        VStack(spacing: GoldRushTheme.Spacing.sm) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(GoldRushTheme.Gradients.goldShimmer)
            Text("Gold Rush Premium")
                .font(GoldRushTheme.Typography.display(28))
                .foregroundStyle(GoldRushTheme.Colors.parchment)
            Text("One-time purchases. No subscriptions. Ever.")
                .font(GoldRushTheme.Typography.body(15))
                .foregroundStyle(GoldRushTheme.Colors.ironGray)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, GoldRushTheme.Spacing.lg)
    }

    private func restoreButton(vm: StoreViewModel) -> some View {
        GoldButton(
            title: "Restore Purchases",
            action: { Task { await vm.restore() } },
            style: .secondary
        )
    }

    private var legalText: some View {
        Text("Prices shown are in your local currency. Purchases are non-refundable except as required by law. All content is stored on-device.")
            .font(GoldRushTheme.Typography.caption(11))
            .foregroundStyle(GoldRushTheme.Colors.ironGray.opacity(0.6))
            .multilineTextAlignment(.center)
    }
}

// MARK: - Product Card

private struct ProductCard: View {
    let product: StoreProduct
    let isPurchased: Bool
    let isPurchasing: Bool
    let onPurchase: () -> Void

    var body: some View {
        DarkCard {
            VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.md) {
                productHeader
                Divider().background(GoldRushTheme.Colors.richGold.opacity(0.2))
                featureList
                purchaseButton
            }
            .padding(GoldRushTheme.Spacing.lg)
        }
        .overlay {
            if isPurchased {
                RoundedRectangle(cornerRadius: GoldRushTheme.Radius.lg)
                    .strokeBorder(GoldRushTheme.Colors.mossGreen, lineWidth: 2)
            }
        }
    }

    private var productHeader: some View {
        HStack {
            Image(systemName: product.iconName)
                .font(.system(size: 32))
                .foregroundStyle(GoldRushTheme.Gradients.goldShimmer)

            VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.xxs) {
                Text(product.displayTitle)
                    .font(GoldRushTheme.Typography.heading(20))
                    .foregroundStyle(GoldRushTheme.Colors.parchment)
                Text(product.tagline)
                    .font(GoldRushTheme.Typography.caption(13))
                    .foregroundStyle(GoldRushTheme.Colors.ironGray)
            }

            Spacer()

            if isPurchased {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(GoldRushTheme.Colors.mossGreen)
                    .font(.system(size: 24))
            }
        }
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: GoldRushTheme.Spacing.xs) {
            ForEach(product.features, id: \.self) { feature in
                HStack(alignment: .top, spacing: GoldRushTheme.Spacing.xs) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(GoldRushTheme.Colors.richGold)
                        .frame(width: 16)
                    Text(feature)
                        .font(GoldRushTheme.Typography.body(14))
                        .foregroundStyle(GoldRushTheme.Colors.parchmentDark)
                }
            }
        }
    }

    private var purchaseButton: some View {
        GoldButton(
            title: isPurchased ? "Purchased" : "Unlock — 1.99$",
            action: onPurchase,
            isLoading: isPurchasing
        )
        .disabled(isPurchased || isPurchasing)
        .opacity(isPurchased ? 0.6 : 1.0)
    }
}
