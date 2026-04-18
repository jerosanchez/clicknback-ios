//

@testable import ClickNBack
import Testing

@MainActor
@Suite("SignInAnalyticsEvents")
struct SignInAnalyticsEventTests {

    // MARK: - name

    @Test
    func name_returnsLoginScreenShowed_forLoginScreenShowedCase() {
        // Arrange
        let sut = SignInAnalyticsEvents.loginScreenShowed

        // Assert
        #expect(sut.name == "login-screen-showed")
    }

    @Test
    func name_returnsLoginSucceeded_forLoginSucceededCase() {
        // Arrange
        let sut = SignInAnalyticsEvents.loginSucceeded(email: "user@example.com")

        // Assert
        #expect(sut.name == "login-succeeded")
    }

    // MARK: - properties

    @Test
    func properties_isEmpty_forLoginScreenShowedCase() {
        // Arrange
        let sut = SignInAnalyticsEvents.loginScreenShowed

        // Assert
        #expect(sut.properties.isEmpty)
    }

    @Test
    func properties_containsEmail_forLoginSucceededCase() {
        // Arrange
        let email = "user@example.com"
        let sut = SignInAnalyticsEvents.loginSucceeded(email: email)

        // Assert
        #expect(sut.properties["email"] as? String == email)
    }

    @Test
    func properties_containsOnlyEmailKey_forLoginSucceededCase() {
        // Arrange
        let sut = SignInAnalyticsEvents.loginSucceeded(email: "user@example.com")

        // Assert
        #expect(sut.properties.count == 1)
    }
}
