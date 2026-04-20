//

import Foundation

public enum SplashAnalyticsEvent: AnalyticsEvent {
    case splashScreenShowed

    public var name: String {
        switch self {
        case .splashScreenShowed: "splash-screen-showed"
        }
    }

    public var properties: [String: Any] {
        switch self {
        case .splashScreenShowed: [:]
        }
    }
}
