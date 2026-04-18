//

import Foundation

public final class MockAnalyticsTracker: AnalyticsTracker {
    public private(set) var trackedEventNames: [String] = []

    public init() {}

    public func track(_ event: AnalyticsEvent) {
        trackedEventNames.append(event.name)
    }
}
