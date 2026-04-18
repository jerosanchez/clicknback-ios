//

@testable import ClickNBack
import Foundation
import Testing

@MainActor
@Suite("Sign In – Integration")
struct SignInIntegrationTests {

    let baseURL = URL(string: "https://api.example.com")!

    // MARK: - signInTapped – state

    @Test
    func signInTapped_returnsSuccess_onValidCredentials() async {
        // Arrange
        let (sut, _, _) = makeSUT()
        MockURLProtocol.stub(data: encoded(makeLoginSuccessResponse()), statusCode: 200)
        sut.email = "user@example.com"
        sut.password = "secret"

        // Act
        await sut.signInTapped()

        // Assert
        #expect(sut.state == .success)
    }

    @Test
    func signInTapped_returnsBadCredentials_on401Response() async {
        // Arrange
        let (sut, _, _) = makeSUT()
        MockURLProtocol.stub(data: Data(), statusCode: 401)
        sut.email = "user@example.com"
        sut.password = "wrong-password"

        // Act
        await sut.signInTapped()

        // Assert
        #expect(sut.state == .error(.badCredentials))
    }

    @Test
    func signInTapped_returnsServerError_on500Response() async {
        // Arrange
        let (sut, _, _) = makeSUT()
        MockURLProtocol.stub(data: Data(), statusCode: 500)
        sut.email = "user@example.com"
        sut.password = "secret"

        // Act
        await sut.signInTapped()

        // Assert
        #expect(sut.state == .error(.serverError))
    }

    @Test
    func signInTapped_returnsNoConnectivity_onNetworkUnavailable() async {
        // Arrange
        let (sut, _, _) = makeSUT()
        MockURLProtocol.stub(error: URLError(.notConnectedToInternet))
        sut.email = "user@example.com"
        sut.password = "secret"

        // Act
        await sut.signInTapped()

        // Assert
        #expect(sut.state == .error(.noConnectivity))
    }

    @Test
    func signInTapped_returnsTimeout_onRequestTimedOut() async {
        // Arrange
        let (sut, _, _) = makeSUT()
        MockURLProtocol.stub(error: URLError(.timedOut))
        sut.email = "user@example.com"
        sut.password = "secret"

        // Act
        await sut.signInTapped()

        // Assert
        #expect(sut.state == .error(.timeout))
    }

    // MARK: - signInTapped – token storage

    @Test
    func signInTapped_storesAccessToken_onValidCredentials() async {
        // Arrange
        let (sut, tokenStorage, _) = makeSUT()
        let response = makeLoginSuccessResponse(accessToken: "test-access-token")
        MockURLProtocol.stub(data: encoded(response), statusCode: 200)
        sut.email = "user@example.com"
        sut.password = "secret"

        // Act
        await sut.signInTapped()

        // Assert
        #expect(tokenStorage.value(forKey: AuthTokensStorageKey.authAccessToken.rawValue) == response.accessToken)
    }

    @Test
    func signInTapped_storesRefreshToken_onValidCredentials() async {
        // Arrange
        let (sut, tokenStorage, _) = makeSUT()
        let response = makeLoginSuccessResponse(refreshToken: "test-refresh-token")
        MockURLProtocol.stub(data: encoded(response), statusCode: 200)
        sut.email = "user@example.com"
        sut.password = "secret"

        // Act
        await sut.signInTapped()

        // Assert
        #expect(tokenStorage.value(forKey: AuthTokensStorageKey.authRefreshToken.rawValue) == response.refreshToken)
    }

    // MARK: - Helpers

    private func makeSUT() -> (
        sut: SignInViewModel,
        tokenStorage: MockKeyValueStorage,
        analytics: MockAnalyticsTracker
    ) {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        let apiClient = PublicAPIClient(baseURL: baseURL, session: session)
        let authRepository = RemoteAuthRepository(apiClient: apiClient)
        let tokenStorage = MockKeyValueStorage()
        let loginUseCase = LoginUseCase(authRepository: authRepository, tokenStorage: tokenStorage)
        let analytics = MockAnalyticsTracker()
        let sut = SignInViewModel(loginUseCase: loginUseCase, analyticsTracker: analytics)

        return (sut, tokenStorage, analytics)
    }

    private func makeLoginSuccessResponse(
        accessToken: String = "access-token",
        refreshToken: String = "refresh-token",
        tokenType: String = "bearer"
    ) -> LoginSuccessResponse {
        LoginSuccessResponse(accessToken: accessToken, refreshToken: refreshToken, tokenType: tokenType)
    }

    /// Serializes a LoginSuccessResponse to JSON using the server's snake_case wire format,
    /// matching the CodingKeys defined on LoginSuccessResponse.
    private func encoded(_ response: LoginSuccessResponse) -> Data {
        let dict: [String: Any] = [
            "access_token": response.accessToken,
            "refresh_token": response.refreshToken,
            "token_type": response.tokenType,
        ]
        return (try? JSONSerialization.data(withJSONObject: dict)) ?? Data()
    }
}
