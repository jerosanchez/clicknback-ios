//

import Foundation

public protocol AnalyticsEvent {
    var name: String { get }
    var properties: [String: Any] { get }
}
