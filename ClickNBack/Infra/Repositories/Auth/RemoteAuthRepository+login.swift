//

import Foundation

public struct LoginSuccessResponse: Decodable {
    public let accessToken: String
    public let refreshToken: String
    public let tokenType: String

    public init(accessToken: String, refreshToken: String, tokenType: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
    }

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
    }
}

extension RemoteAuthRepository {
    public func login(with credentials: LoginCredentials) async -> LoginResult {
        let loginRequest = AuthAPIRequest.login(
            email: credentials.email,
            password: credentials.password
        )

        let result: Result<LoginSuccessResponse, APIClientError> = await apiClient.request(apiRequest: loginRequest)

        switch result {
        case let .success(tokens):
            return .success(tokens.toAuthTokens())

        case let .failure(error):
            switch error {
            case .apiError:
                // TODO: Handle specific API error codes to differentiate between bad credentials and other errors
                return .failure(.badCredentials)
            case .requestTimeout:
                return .failure(.requestTimeout)
            case .noConnection:
                return .failure(.noConnectivity)
            default:
                return .failure(.unexpectedError(error))
            }
        }
    }

    // MARK: - Helper methods

    private func unexpectedError(_ error: Error? = nil) -> LoginResult {
        return .failure(.unexpectedError(error))
    }
}

private extension LoginSuccessResponse {
    func toAuthTokens() -> AuthTokens {
        AuthTokens(accessToken: accessToken, refreshToken: refreshToken)
    }
}
