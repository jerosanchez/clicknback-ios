//

import Foundation

enum SignInAnalyticsEvents: AnalyticsEvent {
    case loginScreenShowed
    case loginSucceeded(email: String)

    var name: String {
        switch self {
        case .loginScreenShowed: "login-screen-showed"
        case .loginSucceeded: "login-succeeded"
        }
    }

    var properties: [String: Any] {
        switch self {
        case let .loginSucceeded(email):
            ["email": email]
        case .loginScreenShowed: [:]
        }
    }
}
