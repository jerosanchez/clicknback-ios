//

import Foundation

enum OffersAnalyticsEvent: AnalyticsEvent {
    case screenShowed

    var name: String {
        switch self {
        case .screenShowed: "offers-screen-showed"
        }
    }

    var properties: [String: Any] {
        switch self {
        case .screenShowed: [:]
        }
    }
}
