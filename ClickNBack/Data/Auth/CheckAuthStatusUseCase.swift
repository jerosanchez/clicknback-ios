//

public final class CheckAuthStatusUseCase {
    private let tokenStorage: KeyValueStorage

    public init(tokenStorage: KeyValueStorage) {
        self.tokenStorage = tokenStorage
    }

    public func execute() -> Bool {
        let accessToken = try? tokenStorage.get(String.self, forKey: AuthTokensStorageKey.authAccessToken.rawValue)
        let refreshToken = try? tokenStorage.get(String.self, forKey: AuthTokensStorageKey.authRefreshToken.rawValue)
        return accessToken != nil && refreshToken != nil
    }
}
