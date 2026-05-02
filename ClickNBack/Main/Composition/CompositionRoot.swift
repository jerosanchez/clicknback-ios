//

import Foundation

struct CompositionRoot {

    // MARK: - Infrastructure

    static var apiClient: APIClient {
        PublicAPIClient(
            baseURL: AppConfig.baseURL,
            session: URLSession.shared,
            logger: logger
        )
    }

    static var authenticatedAPIClient: APIClient {
        PrivateAPIClient(
            inner: apiClient,
            tokenStorage: secureStorage,
            logger: logger
        )
    }

    // MARK: - Repositories

    static var offersRepository: OffersRepository {
        RemoteOffersRepository(apiClient: authenticatedAPIClient)
    }

    // MARK: - Cross-cutting Concerns

    static var settingsStorage: KeyValueStorage {
        UserDefaultsStorage()
    }

    // TODO: Replace with Keychain-based storage in production
    static var secureStorage: KeyValueStorage {
        settingsStorage
    }

    static var logger: Logger {
        ConsoleLogger()
    }

    static var analyticsTracker: AnalyticsTracker {
        ComposableAnalyticsTracker(
            trackers: [
                ConsoleAnalyticsTracker()
            ]
        )
    }

    // MARK: - Startup

    static func startupTasks(appState: AppState) -> [any StartupTask] {
        [
            CheckAuthStatusStartupTask(
                useCase: CheckAuthStatusUseCase(tokenStorage: secureStorage),
                appState: appState
            )
        ]
    }
}
