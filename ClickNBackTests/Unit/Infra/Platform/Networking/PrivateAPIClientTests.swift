//

import ClickNBack
import Foundation
import Testing

@Suite("PrivateAPIClient")
@MainActor
struct PrivateAPIClientTests {

    // MARK: - No access token

    @Test
    func request_returnsUnauthorized_whenNoAccessTokenStored() async {
        // Arrange
        let sut = makeSUT()

        // Act
        let result: Result<TestResponse, APIClientError> = await sut.request(
            apiRequest: MockAPIRequest(endpoint: "v1/some-endpoint")
        )

        // Assert
        guard case .failure(.apiError(401, _)) = result else {
            #expect(Bool(false), "Expected .apiError(401, _)")
            return
        }
    }

    @Test
    func request_doesNotCallInner_whenNoAccessTokenStored() async {
        // Arrange
        let inner = MockAPIClient()
        let sut = makeSUT(inner: inner)

        // Act
        let _: Result<TestResponse, APIClientError> = await sut.request(
            apiRequest: MockAPIRequest(endpoint: "v1/some-endpoint")
        )

        // Assert
        #expect(inner.requestHistory.isEmpty)
    }

    // MARK: - Success path

    @Test
    func request_forwardsSuccessResult_whenInnerSucceeds() async {
        // Arrange
        let expected = TestResponse(id: UUID().uuidString)
        let inner = MockAPIClient()
        inner.setMockResponse(expected, for: "v1/some-endpoint")
        let sut = makeSUT(inner: inner, accessToken: UUID().uuidString)

        // Act
        let result: Result<TestResponse, APIClientError> = await sut.request(
            apiRequest: MockAPIRequest(endpoint: "v1/some-endpoint")
        )

        // Assert
        guard case .success(let response) = result else {
            #expect(Bool(false), "Expected success")
            return
        }
        #expect(response.id == expected.id)
    }

    @Test
    func request_callsInnerOnce_whenInnerSucceeds() async {
        // Arrange
        let inner = MockAPIClient()
        let sut = makeSUT(inner: inner, accessToken: UUID().uuidString)

        // Act
        let _: Result<TestResponse, APIClientError> = await sut.request(
            apiRequest: MockAPIRequest(endpoint: "v1/some-endpoint")
        )

        // Assert
        #expect(inner.requestHistory.count == 1)
        #expect(inner.requestHistory.first?.endpoint == "v1/some-endpoint")
    }

    // MARK: - 401 / token refresh

    @Test
    func request_attemptsTokenRefresh_on401Response() async {
        // Arrange
        let inner = MockAPIClient()
        inner.errorQueue = [.apiError(401, nil)]
        inner.setMockResponse(makeRefreshResponse(), for: "v1/auth/refresh")
        let sut = makeSUT(inner: inner, accessToken: UUID().uuidString, refreshToken: UUID().uuidString)

        // Act
        let _: Result<TestResponse, APIClientError> = await sut.request(
            apiRequest: MockAPIRequest(endpoint: "v1/some-endpoint")
        )

        // Assert
        #expect(inner.requestHistory.contains { $0.endpoint == "v1/auth/refresh" })
    }

    @Test
    func request_retriesOriginalRequest_afterSuccessfulRefresh() async {
        // Arrange
        let retryResponse = TestResponse(id: UUID().uuidString)
        let inner = MockAPIClient()
        inner.errorQueue = [.apiError(401, nil)]
        inner.setMockResponse(makeRefreshResponse(), for: "v1/auth/refresh")
        inner.setMockResponse(retryResponse, for: "v1/some-endpoint")
        let sut = makeSUT(inner: inner, accessToken: UUID().uuidString, refreshToken: UUID().uuidString)

        // Act
        let result: Result<TestResponse, APIClientError> = await sut.request(
            apiRequest: MockAPIRequest(endpoint: "v1/some-endpoint")
        )

        // Assert
        guard case .success(let response) = result else {
            #expect(Bool(false), "Expected success after refresh")
            return
        }
        #expect(response.id == retryResponse.id)
    }

    @Test
    func request_updatesStoredTokens_afterSuccessfulRefresh() async {
        // Arrange
        let newAccessToken = UUID().uuidString
        let newRefreshToken = UUID().uuidString
        let inner = MockAPIClient()
        inner.errorQueue = [.apiError(401, nil)]
        inner.setMockResponse(
            makeRefreshResponse(accessToken: newAccessToken, refreshToken: newRefreshToken),
            for: "v1/auth/refresh"
        )
        let storage = makeStorage(accessToken: UUID().uuidString, refreshToken: UUID().uuidString)
        let sut = PrivateAPIClient(inner: inner, tokenStorage: storage, logger: MockLogger())

        // Act
        let _: Result<TestResponse, APIClientError> = await sut.request(
            apiRequest: MockAPIRequest(endpoint: "v1/some-endpoint")
        )

        // Assert
        #expect(storage.value(forKey: AuthTokensStorageKey.authAccessToken.rawValue) == newAccessToken)
        #expect(storage.value(forKey: AuthTokensStorageKey.authRefreshToken.rawValue) == newRefreshToken)
    }

    @Test
    func request_clearsStoredTokens_onRefreshFailure() async {
        // Arrange
        let inner = MockAPIClient()
        inner.errorQueue = [.apiError(401, nil)]
        inner.setMockError(.apiError(401, nil))
        let storage = makeStorage(accessToken: UUID().uuidString, refreshToken: UUID().uuidString)
        let sut = PrivateAPIClient(inner: inner, tokenStorage: storage, logger: MockLogger())

        // Act
        let _: Result<TestResponse, APIClientError> = await sut.request(
            apiRequest: MockAPIRequest(endpoint: "v1/some-endpoint")
        )

        // Assert
        #expect(storage.value(forKey: AuthTokensStorageKey.authAccessToken.rawValue) == nil)
        #expect(storage.value(forKey: AuthTokensStorageKey.authRefreshToken.rawValue) == nil)
    }

    @Test
    func request_returnsRefreshError_onRefreshFailure() async {
        // Arrange
        let inner = MockAPIClient()
        inner.errorQueue = [.apiError(401, nil)]
        inner.setMockError(.noConnection)
        let sut = makeSUT(inner: inner, accessToken: UUID().uuidString, refreshToken: UUID().uuidString)

        // Act
        let result: Result<TestResponse, APIClientError> = await sut.request(
            apiRequest: MockAPIRequest(endpoint: "v1/some-endpoint")
        )

        // Assert
        guard case .failure(.noConnection) = result else {
            #expect(Bool(false), "Expected .noConnection")
            return
        }
    }

    // MARK: - Refresh deduplication

    @Test
    func request_issuedOnlyOneRefresh_onConcurrent401s() async {
        // Arrange
        let inner = MockAPIClient()
        inner.errorQueue = [.apiError(401, nil), .apiError(401, nil)]
        inner.setMockResponse(makeRefreshResponse(), for: "v1/auth/refresh")
        inner.setMockResponse(TestResponse(id: UUID().uuidString), for: "v1/some-endpoint")
        let sut = makeSUT(inner: inner, accessToken: UUID().uuidString, refreshToken: UUID().uuidString)

        // Act — two concurrent requests both hitting 401
        async let r1: Result<TestResponse, APIClientError> = sut.request(
            apiRequest: MockAPIRequest(endpoint: "v1/some-endpoint")
        )
        async let r2: Result<TestResponse, APIClientError> = sut.request(
            apiRequest: MockAPIRequest(endpoint: "v1/some-endpoint")
        )
        _ = await (r1, r2)

        // Assert — exactly one refresh despite two concurrent 401s
        let refreshCount = inner.requestHistory.filter { $0.endpoint == "v1/auth/refresh" }.count
        #expect(refreshCount == 1)
    }

    // MARK: - Helpers

    private func makeSUT(
        inner: MockAPIClient = MockAPIClient(),
        accessToken: String? = nil,
        refreshToken: String? = nil
    ) -> PrivateAPIClient {
        let storage = makeStorage(accessToken: accessToken, refreshToken: refreshToken)
        return PrivateAPIClient(inner: inner, tokenStorage: storage, logger: MockLogger())
    }

    private func makeStorage(
        accessToken: String? = nil,
        refreshToken: String? = nil
    ) -> MockKeyValueStorage {
        let storage = MockKeyValueStorage()
        if let accessToken {
            try? storage.set(accessToken, forKey: AuthTokensStorageKey.authAccessToken.rawValue)
        }
        if let refreshToken {
            try? storage.set(refreshToken, forKey: AuthTokensStorageKey.authRefreshToken.rawValue)
        }
        return storage
    }

    private func makeRefreshResponse(
        accessToken: String = UUID().uuidString,
        refreshToken: String = UUID().uuidString
    ) -> LoginSuccessResponse {
        LoginSuccessResponse(accessToken: accessToken, refreshToken: refreshToken, tokenType: "Bearer")
    }
}

// MARK: - Test helpers

private struct TestResponse: Decodable, Equatable {
    let id: String
}
