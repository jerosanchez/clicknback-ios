import Foundation

extension RemotePurchasesRepository {
    public func fetchUserPurchases(offset: Int, limit: Int) async -> FetchUserPurchasesResult {
        let result: Result<PaginatedUserPurchasesResponse, APIClientError> =
            await apiClient.request(apiRequest: PurchasesAPIRequest.listUserPurchases(
                offset: offset,
                limit: limit
            ))

        switch result {
        case .success(let response):
            return .success(response.toPurchasesPage())
        case .failure(let error):
            switch error {
            case .apiError(401, _):
                return .failure(.unauthorized)
            case .apiError:
                return .failure(.unexpectedError)
            case .serverError:
                return .failure(.serverError)
            case .requestTimeout:
                return .failure(.requestTimeout)
            case .noConnection:
                return .failure(.noConnectivity)
            default:
                return .failure(.unexpectedError)
            }
        }
    }
}

// MARK: - Helpers

private extension PaginatedUserPurchasesResponse {
    func toPurchasesPage() -> PurchasesPage {
        PurchasesPage(
            purchases: data.map { $0.toPurchase() },
            pagination: Pagination(
                offset: pagination.offset,
                limit: pagination.limit,
                total: pagination.total
            )
        )
    }
}

private extension UserPurchaseResponse {
    func toPurchase() -> Purchase {
        let formatter = ISO8601DateFormatter()
        return Purchase(
            id: id,
            merchantName: merchantName,
            amount: Decimal(string: amount) ?? .zero,
            status: PurchaseStatus(rawValue: status) ?? .pending,
            cashbackAmount: Decimal(string: cashbackAmount) ?? .zero,
            cashbackStatus: cashbackStatus,
            createdAt: formatter.date(from: createdAt) ?? Date()
        )
    }
}
