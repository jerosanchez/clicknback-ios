//

@testable import ClickNBack
import Testing

@MainActor
@Suite("OffersAnalyticsEvent")
struct OffersAnalyticsEventTests {

    // MARK: - name

    @Test
    func name_returnsOffersScreenShowed_forScreenShowedCase() {
        // Arrange
        let sut = OffersAnalyticsEvent.screenShowed

        // Assert
        #expect(sut.name == "offers-screen-showed")
    }

    // MARK: - properties

    @Test
    func properties_isEmpty_forScreenShowedCase() {
        // Arrange
        let sut = OffersAnalyticsEvent.screenShowed

        // Assert
        #expect(sut.properties.isEmpty)
    }
}
