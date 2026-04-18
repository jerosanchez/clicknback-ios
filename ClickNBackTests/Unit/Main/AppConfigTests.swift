//

@testable import ClickNBack
import Testing

@MainActor
@Suite("AppConfig")
struct AppConfigTests {

    // MARK: - baseURL

    @Test
    func baseURL_pointsToProductionDomain_forProductionEnvironment() {
        // Arrange
        let original = AppConfig.environment
        defer { AppConfig.environment = original }
        AppConfig.environment = .production

        // Assert
        #expect(AppConfig.baseURL.absoluteString.contains("clicknback.com/api"))
    }

    @Test
    func baseURL_pointsToStagingDomain_forStagingEnvironment() {
        // Arrange
        let original = AppConfig.environment
        defer { AppConfig.environment = original }
        AppConfig.environment = .staging

        // Assert
        #expect(AppConfig.baseURL.absoluteString.contains("dev.clicknback.com/api"))
    }

    @Test
    func baseURL_isValidURL_forProductionEnvironment() {
        // Arrange
        let original = AppConfig.environment
        defer { AppConfig.environment = original }
        AppConfig.environment = .production

        // Assert
        #expect(AppConfig.baseURL.scheme == "https")
    }

    @Test
    func baseURL_isValidURL_forStagingEnvironment() {
        // Arrange
        let original = AppConfig.environment
        defer { AppConfig.environment = original }
        AppConfig.environment = .staging

        // Assert
        #expect(AppConfig.baseURL.scheme == "https")
    }
}
