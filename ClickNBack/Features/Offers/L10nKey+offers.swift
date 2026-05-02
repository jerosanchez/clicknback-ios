//

import Foundation

// swiftlint:disable nesting
extension L10nKey {
    enum Offers {
        enum Screen {
            static let title = LocalizedStringResource("offers.screen.title", table: "Offers")
        }

        enum EmptyState {
            static let title = LocalizedStringResource("offers.emptyState.title", table: "Offers")
            static let message = LocalizedStringResource("offers.emptyState.message", table: "Offers")
        }

        enum Error {
            static let message = LocalizedStringResource("offers.error.message", table: "Offers")
            static let retryButton = LocalizedStringResource("offers.error.retryButton", table: "Offers")
        }
    }
}
// swiftlint:enable nesting
