//

import Foundation

public struct MockAnalyticsEvent: AnalyticsEvent {
    public let name: String
    public let properties: [String: Any]

    public init(name: String = "mock-event", properties: [String: Any] = [:]) {
        self.name = name
        self.properties = properties
    }
}
