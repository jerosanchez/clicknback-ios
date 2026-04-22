import Foundation

extension RemoteOffersRepository {
    public func fetchActive(offset: Int, limit: Int) async -> FetchActiveOffersResult {
        let result: Result<PaginatedActiveOffersResponse, APIClientError> =
            await apiClient.request(apiRequest: OffersAPIRequest.listActive(
                offset: offset,
                limit: limit
            ))

        switch result {
        case .success(let response):
            return .success(response.toOffersPage())
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

private extension PaginatedActiveOffersResponse {
    func toOffersPage() -> OffersPage {
        OffersPage(
            offers: data.map { $0.toOffer() },
            pagination: OffersPagination(
                offset: pagination.offset,
                limit: pagination.limit,
                total: pagination.total
            )
        )
    }
}

private extension ActiveOfferResponse {
    func toOffer() -> Offer {
        Offer(
            id: id,
            merchantName: merchantName,
            cashbackType: cashbackType,
            cashbackValue: cashbackValue,
            monthlyCap: monthlyCap,
            startDate: startDate,
            endDate: endDate
        )
    }
}
