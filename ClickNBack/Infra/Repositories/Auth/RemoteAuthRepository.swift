//

import Foundation

final class RemoteAuthRepository: AuthRepository {
    private(set) var apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
}
