//

import ClickNBack
import Testing

@MainActor
@Suite("CheckAuthStatusUseCase")
struct CheckAuthStatusUseCaseTests {

    @Test
    func execute_returnsTrue_whenBothTokensArePresent() {
        // Arrange
        let storage = MockKeyValueStorage()
        try? storage.set("access-token", forKey: AuthTokensStorageKey.authAccessToken.rawValue)
        try? storage.set("refresh-token", forKey: AuthTokensStorageKey.authRefreshToken.rawValue)
        let sut = makeSUT(tokenStorage: storage)

        // Act
        let result = sut.execute()

        // Assert
        #expect(result == true)
    }

    @Test
    func execute_returnsFalse_whenAccessTokenIsMissing() {
        // Arrange
        let storage = MockKeyValueStorage()
        try? storage.set("refresh-token", forKey: AuthTokensStorageKey.authRefreshToken.rawValue)
        let sut = makeSUT(tokenStorage: storage)

        // Act
        let result = sut.execute()

        // Assert
        #expect(result == false)
    }

    @Test
    func execute_returnsFalse_whenRefreshTokenIsMissing() {
        // Arrange
        let storage = MockKeyValueStorage()
        try? storage.set("access-token", forKey: AuthTokensStorageKey.authAccessToken.rawValue)
        let sut = makeSUT(tokenStorage: storage)

        // Act
        let result = sut.execute()

        // Assert
        #expect(result == false)
    }

    @Test
    func execute_returnsFalse_whenNoTokensArePresent() {
        // Arrange
        let sut = makeSUT()

        // Act
        let result = sut.execute()

        // Assert
        #expect(result == false)
    }

    // MARK: - Factory

    private func makeSUT(
        tokenStorage: KeyValueStorage = MockKeyValueStorage()
    ) -> CheckAuthStatusUseCase {
        CheckAuthStatusUseCase(tokenStorage: tokenStorage)
    }
}
