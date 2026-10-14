import StoreKit
import SwiftUI
import LifeProgressShared

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

struct TipStyle {
    let title: String
    let icon: String

    static func forProduct(_ productID: String) -> TipStyle {
        switch productID {
        case TipStore.productIDs[0]:
            return TipStyle(
                title: "Buy me a cola",
                icon: "takeoutbag.and.cup.and.straw"
            )
        case TipStore.productIDs[1]:
            return TipStyle(
                title: "Buy me an ice cream",
                icon: "birthday.cake"
            )
        default:
            return TipStyle(
                title: "Buy me a coffee",
                icon: "cup.and.saucer"
            )
        }
    }
}
