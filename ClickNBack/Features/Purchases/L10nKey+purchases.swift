//

import Foundation

// swiftlint:disable nesting
extension L10nKey {
    enum Purchases {
        enum Screen {
            static let title = LocalizedStringResource("purchases.screen.title", table: "Purchases")
        }

        enum EmptyState {
            static let title = LocalizedStringResource("purchases.emptyState.title", table: "Purchases")
            static let message = LocalizedStringResource("purchases.emptyState.message", table: "Purchases")
        }

        enum Error {
            static let message = LocalizedStringResource("purchases.error.message", table: "Purchases")
            static let retryButton = LocalizedStringResource("purchases.error.retryButton", table: "Purchases")
        }

        enum Row {
            static let cashbackLabel = LocalizedStringResource("purchases.row.cashbackLabel", table: "Purchases")
        }

        enum Status {
            static let pending = LocalizedStringResource("purchases.status.pending", table: "Purchases")
            static let confirmed = LocalizedStringResource("purchases.status.confirmed", table: "Purchases")
            static let reversed = LocalizedStringResource("purchases.status.reversed", table: "Purchases")
            static let rejected = LocalizedStringResource("purchases.status.rejected", table: "Purchases")
        }
    }
}
// swiftlint:enable nesting
