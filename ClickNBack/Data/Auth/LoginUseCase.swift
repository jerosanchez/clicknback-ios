//

import Foundation

public enum LoginUseCaseResult {
    case success
    case badCredentials
    case serverError
    case requestTimeout
    case noConnectivity
    case unexpectedError
}

public final class LoginUseCase {
    private var authRepository: AuthRepository
    private var tokenStorage: KeyValueStorage

    public init(
        authRepository: AuthRepository,
        tokenStorage: KeyValueStorage
    ) {
        self.authRepository = authRepository
        self.tokenStorage = tokenStorage
    }

    public func execute(with credentials: LoginCredentials) async -> LoginUseCaseResult {
        let loginResult = await authRepository.login(with: credentials)

        switch loginResult {
        case let .success(authTokens):
        do {
            try tokenStorage.set(
                authTokens.accessToken,
                forKey: AuthTokensStorageKey.authAccessToken.rawValue
            )
            try tokenStorage.set(
                authTokens.refreshToken,
                forKey: AuthTokensStorageKey.authRefreshToken.rawValue
            )
            return .success
        } catch {
            // TODO: Log this error, since it shouldn't happen under normal circumstances
            // and indicates a problem with the storage mechanism
            return .unexpectedError
        }

        case let .failure(error):
            switch error {
            case .badCredentials:
                return .badCredentials
            case .serverError:
                return .serverError
            case .noConnectivity:
                return .noConnectivity
            case .requestTimeout:
                return .requestTimeout
            case .unexpectedError:
                return .unexpectedError
            }
        }
    }
}
