//

import Foundation

public final class ConsoleAnalyticsTracker: AnalyticsTracker {
    private let dateFormatter: DateFormatter

    public init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        dateFormatter = formatter
    }

    public func track(_ event: AnalyticsEvent) {
        let timestamp = dateFormatter.string(from: Date())
        print("📊 [\(timestamp)] EVENT: \(event.name) -> \(event.properties)")
    }
}
