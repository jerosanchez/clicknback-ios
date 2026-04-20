//

import Foundation

@Observable public final class SplashViewModel {
    private let analyticsTracker: AnalyticsTracker

    public init(analyticsTracker: AnalyticsTracker) {
        self.analyticsTracker = analyticsTracker
    }

    public func onAppear() {
        Task {
            await analyticsTracker.track(SplashAnalyticsEvent.splashScreenShowed)
        }
    }
}
