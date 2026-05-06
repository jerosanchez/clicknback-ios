//

@testable import ClickNBack
import Testing

@MainActor
@Suite("PurchasesAnalyticsEvent")
struct PurchasesAnalyticsEventTests {

    // MARK: - name

    @Test
    func name_returnsPurchasesScreenShowed_forScreenShowedCase() {
        // Arrange
        let sut = PurchasesAnalyticsEvent.screenShowed

        // Assert
        #expect(sut.name == "purchases-screen-showed")
    }

    // MARK: - properties

    @Test
    func properties_isEmpty_forScreenShowedCase() {
        // Arrange
        let sut = PurchasesAnalyticsEvent.screenShowed

        // Assert
        #expect(sut.properties.isEmpty)
    }
}
