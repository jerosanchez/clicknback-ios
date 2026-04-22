import Foundation

public final class RemoteOffersRepository: OffersRepository {
    private(set) var apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
}
