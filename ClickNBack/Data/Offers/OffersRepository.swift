public typealias FetchActiveOffersResult = Result<OffersPage, FetchActiveOffersError>

public protocol OffersRepository {
    func fetchActive(offset: Int, limit: Int) async -> FetchActiveOffersResult
}
