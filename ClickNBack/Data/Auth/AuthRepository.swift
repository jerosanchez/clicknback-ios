//

public enum LoginError: Error {
    case badCredentials
    case serverError
    case requestTimeout
    case noConnectivity
    case unexpectedError(Error?)
}

public typealias LoginResult = Result<AuthTokens, LoginError>

public protocol AuthRepository {
    func login(with credentials: LoginCredentials) async -> LoginResult
}
