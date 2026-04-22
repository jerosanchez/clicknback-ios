//

@testable import ClickNBack
import Foundation
import Testing

@MainActor
@Suite("Startup Flow – Integration")
final class StartupFlowIntegrationTests {

    private var createdSuiteNames: [String] = []

    deinit {
        createdSuiteNames.forEach { UserDefaults().removePersistentDomain(forName: $0) }
    }

    // MARK: - startupFlow – authStatus

    @Test
    func startupFlow_setsAuthenticatedStatus_whenBothTokensArePersisted() async throws {
        // Arrange
        let (task, appState, storage) = makeSUT()
        try storage.set("access-token", forKey: AuthTokensStorageKey.authAccessToken.rawValue)
        try storage.set("refresh-token", forKey: AuthTokensStorageKey.authRefreshToken.rawValue)

        // Act
        await task.run()

        // Assert
        #expect(appState.authStatus == .authenticated)
    }

    @Test
    func startupFlow_setsUnauthenticatedStatus_whenStorageIsEmpty() async {
        // Arrange
        let (task, appState, _) = makeSUT()

        // Act
        await task.run()

        // Assert
        #expect(appState.authStatus == .unauthenticated)
    }

    @Test
    func startupFlow_setsUnauthenticatedStatus_whenOnlyAccessTokenIsPersisted() async throws {
        // Arrange
        let (task, appState, storage) = makeSUT()
        try storage.set("access-token", forKey: AuthTokensStorageKey.authAccessToken.rawValue)

        // Act
        await task.run()

        // Assert
        #expect(appState.authStatus == .unauthenticated)
    }

    @Test
    func startupFlow_setsUnauthenticatedStatus_whenOnlyRefreshTokenIsPersisted() async throws {
        // Arrange
        let (task, appState, storage) = makeSUT()
        try storage.set("refresh-token", forKey: AuthTokensStorageKey.authRefreshToken.rawValue)

        // Act
        await task.run()

        // Assert
        #expect(appState.authStatus == .unauthenticated)
    }

    @Test
    func startupFlow_startsInCheckingStatus_beforeRunning() {
        // Arrange
        let (_, appState, _) = makeSUT()

        // Assert
        #expect(appState.authStatus == .checking)
    }

    // MARK: - Helpers

    // Builds the full chain using real UserDefaultsStorage (no mocked storage layer).
    // swiftlint:disable:next large_tuple
    private func makeSUT() -> (task: CheckAuthStatusStartupTask, appState: AppState, storage: UserDefaultsStorage) {
        let suiteName = "com.clicknback.tests.startup.\(UUID().uuidString)"
        createdSuiteNames.append(suiteName)
        let defaults = UserDefaults(suiteName: suiteName)!
        let storage = UserDefaultsStorage(defaults: defaults)
        let appState = AppState()
        let task = CheckAuthStatusStartupTask(
            useCase: CheckAuthStatusUseCase(tokenStorage: storage),
            appState: appState,
            minimumSplashDuration: .zero
        )
        return (task, appState, storage)
    }
}
