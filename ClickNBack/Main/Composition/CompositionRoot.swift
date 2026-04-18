//

import Foundation

struct CompositionRoot {
    
    // MARK: - Infrastructure
    
    static var apiClient: APIClient {
        PublicAPIClient(
            baseURL: AppConfig.baseURL,
            session: URLSession.shared
        )
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
}
