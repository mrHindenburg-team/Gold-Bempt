import StoreKit
import Foundation

@Observable
final class StoreViewModel {

    var products: [Product] = []
    var purchasedIDs: Set<String> = []
    var isLoading = false
    var isPurchasing = false
    var errorMessage: String?
    var successMessage: String?

    private let storeKit: StoreKitService

    init(storeKit: StoreKitService) {
        self.storeKit = storeKit
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        await storeKit.loadProducts()
        products    = storeKit.products
        purchasedIDs = storeKit.purchasedProductIDs
    }

    func purchase(_ storeProduct: StoreProduct) async {
        guard let product = storeKit.product(for: storeProduct) else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await storeKit.purchase(product)
            purchasedIDs = storeKit.purchasedProductIDs
            successMessage = "\(storeProduct.displayTitle) unlocked! Thank you."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restore() async {
        await storeKit.restorePurchases()
        purchasedIDs = storeKit.purchasedProductIDs
        successMessage = "Purchases restored."
    }

    func isPurchased(_ product: StoreProduct) -> Bool {
        purchasedIDs.contains(product.rawValue)
    }
}
