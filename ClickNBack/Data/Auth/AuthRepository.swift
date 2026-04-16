//

enum LoginError: Error {
    case badCredentials
    case requestTimeout
    case noInternetConnection
    case unexpectedError(Error?)
}

typealias LoginResult = Result<AuthTokens, LoginError>

protocol AuthRepository {
    func login(with credentials: LoginCredentials) async -> LoginResult
}
