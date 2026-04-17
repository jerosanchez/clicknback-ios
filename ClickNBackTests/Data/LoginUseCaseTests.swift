//

import ClickNBack
import Testing

@MainActor
@Suite("LoginUseCase")
struct LoginUseCaseTests {

    private let credentials = LoginCredentials(email: "user@example.com", password: "secret")
    private let tokens = AuthTokens.mock

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
        let repository = MockAuthRepository()
        repository.loginHandler = { _ in .failure(.badCredentials) }
        let sut = makeSUT(authRepository: repository)

        // Act
        let result = await sut.execute(with: credentials)

        // Assert
        #expect(result == .badCredentials)
    }
    
    @Test
    func execute_returnsServerError_onServerError() async {
        // Arrange
        let repository = MockAuthRepository()
        repository.loginHandler = { _ in .failure(.serverError) }
        let sut = makeSUT(authRepository: repository)

        // Act
        let result = await sut.execute(with: credentials)

        // Assert
        #expect(result == .serverError)
    }

    @Test
    func execute_returnsNoConnectivity_onNoConnectivityError() async {
        // Arrange
        let repository = MockAuthRepository()
        repository.loginHandler = { _ in .failure(.noConnectivity) }
        let sut = makeSUT(authRepository: repository)

        // Act
        let result = await sut.execute(with: credentials)

        // Assert
        #expect(result == .noConnectivity)
    }

    @Test
    func execute_returnsRequestTimeout_onRequestTimeoutError() async {
        // Arrange
        let repository = MockAuthRepository()
        repository.loginHandler = { _ in .failure(.requestTimeout) }
        let sut = makeSUT(authRepository: repository)

        // Act
        let result = await sut.execute(with: credentials)

        // Assert
        #expect(result == .requestTimeout)
    }

    @Test
    func execute_returnsUnexpectedError_onUnexpectedError() async {
        // Arrange
        let repository = MockAuthRepository()
        repository.loginHandler = { _ in .failure(.unexpectedError(nil)) }
        let sut = makeSUT(authRepository: repository)

        // Act
        let result = await sut.execute(with: credentials)

        // Assert
        #expect(result == .unexpectedError)
    }

    @Test
    func execute_returnsUnexpectedError_whenTokenStorageThrows() async {
        // Arrange
        let failingStorage = MockKeyValueStorage()
        failingStorage.setHandler = { _, _ in throw MockStorageError() }
        let sut = makeSUT(tokenStorage: failingStorage)

        // Act
        let result = await sut.execute(with: credentials)

        // Assert
        #expect(result == .unexpectedError)
    }

    // MARK: - Helpers

    private func makeSUT(
        authRepository: AuthRepository = MockAuthRepository(),
        tokenStorage: KeyValueStorage = MockKeyValueStorage()
    ) -> LoginUseCase {
        LoginUseCase(authRepository: authRepository, tokenStorage: tokenStorage)
    }

    private struct MockStorageError: Error {}
}
