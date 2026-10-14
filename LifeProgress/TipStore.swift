import StoreKit
import SwiftUI

@MainActor
@Observable
final class TipStore {
    static let productIDs = [
        "com.v2free.LifeProgress.tip.small",
        "com.v2free.LifeProgress.tip.medium",
        "com.v2free.LifeProgress.tip.large",
    ]

    var products: [Product] = []
    var isPurchasing = false
    var showThankYou = false
    var errorMessage: String?

    @ObservationIgnored nonisolated private let updatesTask: Task<Void, Never>

    init() {
        updatesTask = Task {
            for await update in Transaction.updates {
                if let transaction = try? TipStore.checkVerified(update) {
                    await transaction.finish()
                }
            }
        }
    }

    deinit {
        updatesTask.cancel()
    }

    func loadProducts() async {
        guard products.isEmpty else { return }
        if let loaded = try? await Product.products(for: Self.productIDs) {
            products = loaded.sorted { $0.price < $1.price }
        }
    }

    func purchase(_ product: Product) async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            switch try await product.purchase() {
            case .success(let result):
                let transaction = try TipStore.checkVerified(result)
                await transaction.finish()
                showThankYou = true
            case .pending:
                errorMessage = "Purchase is pending approval."
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Purchase failed. Please try again later."
        }
    }

    nonisolated private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw StoreError.failedVerification
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
