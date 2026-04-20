//

import ClickNBack
import Testing

@MainActor
@Suite("SplashViewModel")
struct SplashViewModelTests {

    // MARK: - onAppear

    @Test
    func onAppear_tracksSplashScreenShowed() async {
        // Arrange
        let tracker = MockAnalyticsTracker()
        let sut = makeSUT(analyticsTracker: tracker)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(tracker.trackedEventNames == [SplashAnalyticsEvent.splashScreenShowed.name])
    }

    // MARK: - Factory

    private func makeSUT(
        analyticsTracker: AnalyticsTracker = MockAnalyticsTracker()
    ) -> SplashViewModel {
        SplashViewModel(analyticsTracker: analyticsTracker)
    }
}
