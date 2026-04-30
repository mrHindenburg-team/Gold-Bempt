import StoreKit
import Foundation

@Observable
final class StoreKitService {

    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading = false
    var errorMessage: String?

    var hasExplorerPack:  Bool { purchasedProductIDs.contains(StoreProduct.explorerPack.rawValue) }
    var hasHistorianPack: Bool { purchasedProductIDs.contains(StoreProduct.historianPack.rawValue) }

    private var transactionListener:     Task<Void, Never>?
    private var purchaseIntentListener:  Task<Void, Never>?

    init() {
        transactionListener    = listenForTransactions()
        purchaseIntentListener = listenForPurchaseIntents()
    }

    deinit {
        transactionListener?.cancel()
        purchaseIntentListener?.cancel()
    }

    // MARK: - Public

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let ids = StoreProduct.allCases.map(\.rawValue)
            products = try await Product.products(for: ids)
            await updatePurchasedProducts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        try await handlePurchaseResult(result)
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func product(for storeProduct: StoreProduct) -> Product? {
        products.first { $0.id == storeProduct.rawValue }
    }

    // MARK: - Private helpers

    @discardableResult
    private func handlePurchaseResult(_ result: Product.PurchaseResult) async throws -> Transaction? {
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }

    private func updatePurchasedProducts() async {
        var ids: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.revocationDate == nil {
                ids.insert(transaction.productID)
            }
        }
        purchasedProductIDs = ids
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw StoreError.failedVerification
        case .verified(let value): return value
        }
    }

    // Handles transactions pushed from outside the app (e.g. Ask to Buy approvals,
    // subscription renewals, refunds).
    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) {
            for await result in Transaction.updates {
                if let transaction = try? checkVerified(result) {
                    await updatePurchasedProducts()
                    await transaction.finish()
                }
            }
        }
    }

    // Handles promoted in-app purchases tapped from the App Store product page.
    // iOS delivers the intent when the user initiates the purchase outside the app;
    // the app must complete it by calling purchase(options:) on the intent's product.
    private func listenForPurchaseIntents() -> Task<Void, Never> {
        Task(priority: .userInitiated) {
            for await intent in PurchaseIntent.intents {
                do {
                    let result = try await intent.product.purchase()
                    try await handlePurchaseResult(result)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
