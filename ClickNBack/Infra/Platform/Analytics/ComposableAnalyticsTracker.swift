//

import Foundation

public final class ComposableAnalyticsTracker: AnalyticsTracker {
    private let trackers: [AnalyticsTracker]

    public init(trackers: [AnalyticsTracker]) {
        self.trackers = trackers
    }

    public func track(_ event: AnalyticsEvent) {
        trackers.forEach { tracker in
            Task { await tracker.track(event) }
        }
    }
}
