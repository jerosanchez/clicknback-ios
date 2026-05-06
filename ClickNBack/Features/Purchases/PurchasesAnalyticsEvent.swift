//

import Foundation

enum PurchasesAnalyticsEvent: AnalyticsEvent {
    case screenShowed

    var name: String {
        switch self {
        case .screenShowed: "purchases-screen-showed"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .screenShowed: [:]
        }
    }
}
