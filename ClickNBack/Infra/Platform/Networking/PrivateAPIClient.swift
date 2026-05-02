//

import Foundation

@MainActor
public final class PrivateAPIClient: APIClient {
    private let inner: APIClient
    private let tokenStorage: KeyValueStorage
    private let logger: Logger

    private var ongoingRefresh: Task<Result<AuthTokens, APIClientError>, Never>?

    public init(
        inner: APIClient,
        tokenStorage: KeyValueStorage,
        logger: Logger
    ) {
        self.inner = inner
        self.tokenStorage = tokenStorage
        self.logger = logger
    }

    public func request<T: Decodable>(apiRequest: APIRequest) async -> Result<T, APIClientError> {
        guard let accessToken = try? tokenStorage.get(
            String.self,
            forKey: AuthTokensStorageKey.authAccessToken.rawValue
        ) else {
            logger.warning("[\(apiRequest.method.rawValue)] \(apiRequest.endpoint) — no access token in storage")
            return .failure(.apiError(401, nil))
        }

        let result: Result<T, APIClientError> = await inner.request(
            apiRequest: AuthorizedRequest(wrapped: apiRequest, accessToken: accessToken)
        )

        guard case .failure(.apiError(401, _)) = result else {
            return result
        }

        logger.info("[\(apiRequest.method.rawValue)] \(apiRequest.endpoint) — 401 received, attempting token refresh")

        let refreshResult = await refreshTokensIfNeeded()

        switch refreshResult {
        case .success(let newTokens):
            logger.info("Token refresh succeeded, retrying [\(apiRequest.method.rawValue)] \(apiRequest.endpoint)")
            return await inner.request(
                apiRequest: AuthorizedRequest(wrapped: apiRequest, accessToken: newTokens.accessToken)
            )
        case .failure(let error):
            logger.error("Token refresh failed — clearing stored tokens")
            clearTokens()
            return .failure(error)
        }
    }

    // MARK: - Private

    private func refreshTokensIfNeeded() async -> Result<AuthTokens, APIClientError> {
        if let existing = ongoingRefresh {
            return await existing.value
        }

        let task: Task<Result<AuthTokens, APIClientError>, Never> = Task {
            await performRefresh()
        }
        ongoingRefresh = task
        let result = await task.value
        ongoingRefresh = nil
        return result
    }

    private func performRefresh() async -> Result<AuthTokens, APIClientError> {
        guard let refreshToken = try? tokenStorage.get(
            String.self,
            forKey: AuthTokensStorageKey.authRefreshToken.rawValue
        ) else {
            logger.error("Token refresh failed — no refresh token in storage")
            return .failure(.apiError(401, nil))
        }

        let result: Result<LoginSuccessResponse, APIClientError> = await inner.request(
            apiRequest: AuthAPIRequest.refresh(token: refreshToken)
        )

        switch result {
        case .success(let response):
            let newTokens = AuthTokens(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )
            do {
                try tokenStorage.set(newTokens.accessToken, forKey: AuthTokensStorageKey.authAccessToken.rawValue)
                try tokenStorage.set(newTokens.refreshToken, forKey: AuthTokensStorageKey.authRefreshToken.rawValue)
            } catch {
                logger.error("Failed to persist refreshed tokens: \(error)")
            }
            return .success(newTokens)

        case .failure(let error):
            return .failure(error)
        }
    }

    private func clearTokens() {
        try? tokenStorage.remove(forKey: AuthTokensStorageKey.authAccessToken.rawValue)
        try? tokenStorage.remove(forKey: AuthTokensStorageKey.authRefreshToken.rawValue)
    }
}

// MARK: - AuthorizedRequest

private struct AuthorizedRequest: APIRequest {
    private let wrapped: APIRequest
    private let accessToken: String

    init(wrapped: APIRequest, accessToken: String) {
        self.wrapped = wrapped
        self.accessToken = accessToken
    }

    var method: HTTPMethod { wrapped.method }
    var endpoint: String { wrapped.endpoint }
    var queryParams: [String: String]? { wrapped.queryParams }
    var body: [String: Any]? { wrapped.body }

    var headers: [String: String]? {
        var headers = wrapped.headers ?? [:]
        headers["Authorization"] = "Bearer \(accessToken)"
        return headers
    }
}
