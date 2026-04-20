// MARK: - File Placement
//
// Production location                      → Test file location
// Data/<Feature>/                          → Unit/Data/<Feature>/<UseCase>Tests.swift
// Features/<Feature>/                      → Unit/Features/<Feature>/<ViewModel>Tests.swift
// Infra/Repositories/<Feature>/            → Unit/Infra/Repositories/<Feature>/<Repo>+<method>Tests.swift
// Infra/Platform/                          → Unit/Infra/Platform/<category>/<Type>Tests.swift
// Integration tests                        → ClickNBackTests/Integration/ (same mirror)

// MARK: - Suite Boilerplate

import Testing
import ClickNBack

@MainActor
@Suite("LoginUseCase")
struct LoginUseCaseTests {

    // MARK: - Tests

    @Test func execute_returnsSuccess_onValidCredentials() async {
        // Arrange
        let credentials = makeLoginCredentials()
        let sut = makeSUT()

        // Act
        let result = await sut.execute(with: credentials)

        // Assert
        #expect(result == .success)
    }

    @Test func execute_storesAccessToken_onValidCredentials() async {
        // Arrange
        let tokens = AuthTokens(accessToken: "access-token", refreshToken: "refresh-token")
        let repository = MockAuthRepository()
        repository.loginHandler = { _ in .success(tokens) }
        let storage = MockKeyValueStorage()
        let sut = makeSUT(authRepository: repository, tokenStorage: storage)

        // Act
        await sut.execute(with: makeLoginCredentials())

        // Assert
        let stored: String? = storage.value(forKey: AuthTokenStorageKey.authAccessToken.rawValue)
        #expect(stored == tokens.accessToken)
    }

    @Test func execute_returnsBadCredentials_onUnauthorized() async {
        // Arrange
        let repository = MockAuthRepository()
        repository.loginHandler = { _ in .failure(.badCredentials) }
        let sut = makeSUT(authRepository: repository)

        // Act
        let result = await sut.execute(with: makeLoginCredentials())

        // Assert
        #expect(result == .failure(.badCredentials))
    }

    // MARK: - Helpers

    private func makeSUT(
        authRepository: MockAuthRepository = MockAuthRepository(),
        tokenStorage: MockKeyValueStorage = MockKeyValueStorage()
    ) -> LoginUseCase {
        LoginUseCase(authRepository: authRepository, tokenStorage: tokenStorage)
    }

    private func makeLoginCredentials(
        email: String = "user@example.com",
        password: String = "password"
    ) -> LoginCredentials {
        LoginCredentials(email: email, password: password)
    }
}
