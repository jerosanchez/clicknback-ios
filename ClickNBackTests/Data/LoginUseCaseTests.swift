//

import ClickNBack
import Testing

@MainActor
@Suite("LoginUseCase")
struct LoginUseCaseTests {

    private let credentials = LoginCredentials(email: "user@example.com", password: "secret")
    private let tokens = AuthTokens(accessToken: "access-token", refreshToken: "refresh-token")

    @Test
    func execute_returnsSuccess_onValidCredentials() async {
        // Arrange
        let storage = MockKeyValueStorage()
        let sut = makeSUT(tokenStorage: storage)

        // Act
        let result = await sut.execute(with: credentials)

        // Assert
        #expect(result == .success)
    }

    @Test
    func execute_storesTokens_onValidCredentials() async {
        // Arrange
        let storage = MockKeyValueStorage()
        let sut = makeSUT(tokenStorage: storage)

        // Act
        _ = await sut.execute(with: credentials)

        // Assert
        #expect(storage.value(forKey: AuthTokensStorageKey.authAccessToken.rawValue) == tokens.accessToken)
        #expect(storage.value(forKey: AuthTokensStorageKey.authRefreshToken.rawValue) == tokens.refreshToken)
    }

    @Test
    func execute_returnsBadCredentials_onBadCredentialsError() async {
        // Arrange
        let repository = MockAuthRepository(result: .failure(.badCredentials))
        let sut = makeSUT(authRepository: repository)

        // Act
        let result = await sut.execute(with: credentials)

        // Assert
        #expect(result == .badCredentials)
    }
    
    @Test
    func execute_returnsServerError_onServerError() async {
        // Arrange
        let repository = MockAuthRepository(result: .failure(.serverError))
        let sut = makeSUT(authRepository: repository)

        // Act
        let result = await sut.execute(with: credentials)

        // Assert
        #expect(result == .serverError)
    }

    @Test
    func execute_returnsNoConnectivity_onNoConnectivityError() async {
        // Arrange
        let repository = MockAuthRepository(result: .failure(.noConnectivity))
        let sut = makeSUT(authRepository: repository)

        // Act
        let result = await sut.execute(with: credentials)

        // Assert
        #expect(result == .noConnectivity)
    }

    @Test
    func execute_returnsRequestTimeout_onRequestTimeoutError() async {
        // Arrange
        let repository = MockAuthRepository(result: .failure(.requestTimeout))
        let sut = makeSUT(authRepository: repository)

        // Act
        let result = await sut.execute(with: credentials)

        // Assert
        #expect(result == .requestTimeout)
    }

    @Test
    func execute_returnsUnexpectedError_onUnexpectedError() async {
        // Arrange
        let repository = MockAuthRepository(result: .failure(.unexpectedError(nil)))
        let sut = makeSUT(authRepository: repository)

        // Act
        let result = await sut.execute(with: credentials)

        // Assert
        #expect(result == .unexpectedError)
    }

    @Test
    func execute_returnsUnexpectedError_whenTokenStorageThrows() async {
        // Arrange
        let failingStorage = MockKeyValueStorage(throwOnSet: true)
        let sut = makeSUT(tokenStorage: failingStorage)

        // Act
        let result = await sut.execute(with: credentials)

        // Assert
        #expect(result == .unexpectedError)
    }

    // MARK: - Helpers

    private func makeSUT(
        authRepository: AuthRepository = MockAuthRepository(result: .success(AuthTokens(accessToken: "access-token", refreshToken: "refresh-token"))),
        tokenStorage: KeyValueStorage = MockKeyValueStorage()
    ) -> LoginUseCase {
        LoginUseCase(authRepository: authRepository, tokenStorage: tokenStorage)
    }

}

// MARK: - Mocks

private final class MockAuthRepository: AuthRepository {
    private let result: LoginResult

    init(result: LoginResult) {
        self.result = result
    }

    func login(with credentials: LoginCredentials) async -> LoginResult {
        result
    }
}

private final class MockKeyValueStorage: KeyValueStorage {
    private var storage: [String: String] = [:]
    private let throwOnSet: Bool

    init(throwOnSet: Bool = false) {
        self.throwOnSet = throwOnSet
    }

    func value(forKey key: String) -> String? {
        storage[key]
    }

    func set(_ value: some Codable, forKey key: String) throws {
        if throwOnSet { throw MockStorageError() }
        guard let string = value as? String else { return }
        storage[key] = string
    }

    func get<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        storage[key] as? T
    }

    func remove(forKey key: String) throws {
        storage.removeValue(forKey: key)
    }
}

private struct MockStorageError: Error {}

