//

import Foundation

enum LoginUseCaseResult {
    case success
    case badCredentials
    case requestTimeout
    case noConnectivity
    case unexpectedError
}

final class LoginUseCase {
    private var authRepository: AuthRepository
    private var tokenStorage: KeyValueStorage

    init(
        authRepository: AuthRepository,
        tokenStorage: KeyValueStorage
    ) {
        self.authRepository = authRepository
        self.tokenStorage = tokenStorage
    }

    func execute(with credentials: LoginCredentials) async -> LoginUseCaseResult {
        let loginResult = await authRepository.login(with: credentials)

        switch loginResult {
        case let .success(authTokens):
            set(authTokens.accessToken, forKey: .authAccessToken)
            set(authTokens.refreshToken, forKey: .authRefreshToken)
            return .success

        case let .failure(error):
            switch error {
            case .badCredentials:
                return .badCredentials

            case .noConnectivity:
                return .noConnectivity

            case .requestTimeout:
                return .requestTimeout

            case .unexpectedError:
                return .unexpectedError
            }
        }
    }

    // MARK: - - Helper methods

    private func set(_ value: String, forKey key: AuthTokensStorageKey) {
        do {
            try tokenStorage.set(value, forKey: key.rawValue)
        } catch {
            // TODO: Log error to monitoring service
            return
        }
    }
}
