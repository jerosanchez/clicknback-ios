//

import ClickNBack
import Testing

@MainActor
@Suite("SplashAnalyticsEvent")
struct SplashAnalyticsEventTests {

    // MARK: - name

    @Test
    func name_returnsSplashScreenShowed_forSplashScreenShowedCase() {
        // Arrange
        let sut = SplashAnalyticsEvent.splashScreenShowed

        // Assert
        #expect(sut.name == "splash-screen-showed")
    }

    // MARK: - properties

    @Test
    func properties_isEmpty_forSplashScreenShowedCase() {
        // Arrange
        let sut = SplashAnalyticsEvent.splashScreenShowed

        // Assert
        #expect(sut.properties.isEmpty)
    }
}
