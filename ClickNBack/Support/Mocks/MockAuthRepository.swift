//

typealias LoginHandler = (LoginCredentials) async -> LoginResult

final class MockAuthRepository: AuthRepository {
    
    // MARK: - Configurable hooks (optional overrides)

    var loginHandler: LoginHandler?

    // MARK: - API

    func login(with credentials: LoginCredentials) async -> LoginResult {
        await loginHandler?(credentials) ?? .success(.mock)
    }
}
