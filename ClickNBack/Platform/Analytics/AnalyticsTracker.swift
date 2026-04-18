//

import Foundation

public protocol AnalyticsTracker {
    func track(_ event: AnalyticsEvent) async
}
