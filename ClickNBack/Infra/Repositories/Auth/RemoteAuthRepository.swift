//

import Foundation

public final class RemoteAuthRepository: AuthRepository {
    private(set) var apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
}
