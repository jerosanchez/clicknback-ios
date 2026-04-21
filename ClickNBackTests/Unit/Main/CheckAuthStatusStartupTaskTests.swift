//

@testable import ClickNBack
import Testing

@MainActor
@Suite("CheckAuthStatusStartupTask")
struct CheckAuthStatusStartupTaskTests {

    // MARK: - run – authStatus

    @Test
    func run_setsAuthenticatedStatus_whenBothTokensArePresent() async {
        // Arrange
        let storage = MockKeyValueStorage()
        try? storage.set("access-token", forKey: AuthTokensStorageKey.authAccessToken.rawValue)
        try? storage.set("refresh-token", forKey: AuthTokensStorageKey.authRefreshToken.rawValue)
        let appState = AppState()
        let sut = makeSUT(tokenStorage: storage, appState: appState)

        // Act
        await sut.run()

        // Assert
        #expect(appState.authStatus == .authenticated)
    }

    @Test
    func run_setsUnauthenticatedStatus_whenBothTokensAreMissing() async {
        // Arrange
        let appState = AppState()
        let sut = makeSUT(appState: appState)

        // Act
        await sut.run()

        // Assert
        #expect(appState.authStatus == .unauthenticated)
    }

    @Test
    func run_setsUnauthenticatedStatus_whenOnlyAccessTokenIsPresent() async {
        // Arrange
        let storage = MockKeyValueStorage()
        try? storage.set("access-token", forKey: AuthTokensStorageKey.authAccessToken.rawValue)
        let appState = AppState()
        let sut = makeSUT(tokenStorage: storage, appState: appState)

        // Act
        await sut.run()

        // Assert
        #expect(appState.authStatus == .unauthenticated)
    }

    @Test
    func run_setsUnauthenticatedStatus_whenOnlyRefreshTokenIsPresent() async {
        // Arrange
        let storage = MockKeyValueStorage()
        try? storage.set("refresh-token", forKey: AuthTokensStorageKey.authRefreshToken.rawValue)
        let appState = AppState()
        let sut = makeSUT(tokenStorage: storage, appState: appState)

        // Act
        await sut.run()

        // Assert
        #expect(appState.authStatus == .unauthenticated)
    }

    @Test
    func run_startsWithCheckingStatus_beforeCompletion() async {
        // Arrange
        let appState = AppState()

        // Assert (before run)
        #expect(appState.authStatus == .checking)
    }

    // MARK: - Helpers

    private func makeSUT(
        tokenStorage: MockKeyValueStorage = MockKeyValueStorage(),
        appState: AppState = AppState()
    ) -> CheckAuthStatusStartupTask {
        CheckAuthStatusStartupTask(
            useCase: CheckAuthStatusUseCase(tokenStorage: tokenStorage),
            appState: appState,
            minimumSplashDuration: .zero
        )
    }
}
