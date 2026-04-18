//

@testable import ClickNBack
import Testing

@MainActor
@Suite("AuthAPIRequest")
struct AuthAPIRequestTests {

    // MARK: - method

    @Test
    func method_returnsPost_forLoginCase() {
        // Arrange
        let sut = AuthAPIRequest.login(email: "user@example.com", password: "secret")

        // Assert
        #expect(sut.method == .POST)
    }

    // MARK: - endpoint

    @Test
    func endpoint_returnsLoginPath_forLoginCase() {
        // Arrange
        let sut = AuthAPIRequest.login(email: "user@example.com", password: "secret")

        // Assert
        #expect(sut.endpoint == "v1/auth/login")
    }

    // MARK: - headers

    @Test
    func headers_returnsNil_forLoginCase() {
        // Arrange
        let sut = AuthAPIRequest.login(email: "user@example.com", password: "secret")

        // Assert
        #expect(sut.headers == nil)
    }

    // MARK: - queryParams

    @Test
    func queryParams_returnsNil_forLoginCase() {
        // Arrange
        let sut = AuthAPIRequest.login(email: "user@example.com", password: "secret")

        // Assert
        #expect(sut.queryParams == nil)
    }

    // MARK: - body

    @Test
    func body_containsAllFields_forLoginCase() {
        // Arrange
        let email = "user@example.com"
        let password = "secret"
        let sut = AuthAPIRequest.login(email: email, password: password)

        // Assert
        #expect(sut.body?["email"] as? String == email)
        #expect(sut.body?["password"] as? String == password)
    }

    @Test
    func body_doesNotContainExtraFields_forLoginCase() {
        // Arrange
        let sut = AuthAPIRequest.login(email: "user@example.com", password: "secret")

        // Assert
        #expect(sut.body?.count == 2)
    }
}
