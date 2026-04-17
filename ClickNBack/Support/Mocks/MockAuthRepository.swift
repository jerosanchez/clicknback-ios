//

public typealias LoginHandler = (LoginCredentials) async -> LoginResult

public final class MockAuthRepository: AuthRepository {
    
    // MARK: - Configurable hooks (optional overrides)

    public var loginHandler: LoginHandler?

    public init() {}

    // MARK: - API

    public func login(with credentials: LoginCredentials) async -> LoginResult {
        await loginHandler?(credentials) ?? .success(.mock)
    }
}
