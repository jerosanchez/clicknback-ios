//

import ClickNBack
import Testing

@MainActor
@Suite("RemoteAuthRepository.login")
struct RemoteAuthRepositoryLoginTests {

    private let credentials = LoginCredentials(email: "user@example.com", password: "secret")

    @Test
    func login_returnsSuccess_onSuccessfulResponse() async {
        // Arrange
        let tokens = AuthTokens(accessToken: "access-token", refreshToken: "refresh-token")
        let successResponse = LoginSuccessResponse(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
            tokenType: "Bearer"
        )
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(successResponse, for: "v1/auth/login")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.login(with: credentials)

        // Assert
        guard case .success(let returnedTokens) = result else {
            #expect(Bool(false), "Expected success")
            return
        }
        #expect(returnedTokens.accessToken == tokens.accessToken)
        #expect(returnedTokens.refreshToken == tokens.refreshToken)
    }

    @Test
    func login_returnsBadCredentials_onAPIError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.apiError(401, nil))
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.login(with: credentials)

        // Assert
        guard case .failure(.badCredentials) = result else {
            #expect(Bool(false), "Expected badCredentials error")
            return
        }
    }
    
    @Test
    func login_returnsServerError_onServerError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.serverError(503))
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.login(with: credentials)

        // Assert
        guard case .failure(.serverError) = result else {
            #expect(Bool(false), "Expected server error")
            return
        }
    }

    @Test
    func login_returnsRequestTimeout_onRequestTimeoutError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.requestTimeout)
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.login(with: credentials)

        // Assert
        guard case .failure(.requestTimeout) = result else {
            #expect(Bool(false), "Expected requestTimeout error")
            return
        }
    }

    @Test
    func login_returnsNoConnectivity_onNoConnectionError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.noConnection)
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.login(with: credentials)

        // Assert
        guard case .failure(.noConnectivity) = result else {
            #expect(Bool(false), "Expected noConnectivity error")
            return
        }
    }

    @Test
    func login_returnsUnexpectedError_onDecodingError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.decodingError)
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.login(with: credentials)

        // Assert
        guard case .failure(.unexpectedError) = result else {
            #expect(Bool(false), "Expected unexpectedError")
            return
        }
    }

    @Test
    func login_returnsUnexpectedError_onInvalidURLError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.invalidURL)
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.login(with: credentials)

        // Assert
        guard case .failure(.unexpectedError) = result else {
            #expect(Bool(false), "Expected unexpectedError")
            return
        }
    }

    @Test
    func login_returnsUnexpectedError_onUnknownError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.unknownError(nil))
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.login(with: credentials)

        // Assert
        guard case .failure(.unexpectedError) = result else {
            #expect(Bool(false), "Expected unexpectedError")
            return
        }
    }

    // MARK: - Helpers

    private func makeAPIClient(
        response: LoginSuccessResponse = LoginSuccessResponse(
            accessToken: "access-token",
            refreshToken: "refresh-token",
            tokenType: "Bearer"
        ),
        endpoint: String = "v1/auth/login"
    ) -> MockAPIClient {
        let client = MockAPIClient()
        client.setMockResponse(response, for: endpoint)
        return client
    }

    private func makeSUT(apiClient: APIClient? = nil) -> RemoteAuthRepository {
        RemoteAuthRepository(apiClient: apiClient ?? makeAPIClient())
    }
}

