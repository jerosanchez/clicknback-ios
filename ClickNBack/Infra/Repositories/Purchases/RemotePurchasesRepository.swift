import Foundation

public final class RemotePurchasesRepository: PurchasesRepository {
    private(set) var apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
}
