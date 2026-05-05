public typealias FetchUserPurchasesResult = Result<PurchasesPage, FetchUserPurchasesError>

public protocol PurchasesRepository {
    func fetchUserPurchases(offset: Int, limit: Int) async -> FetchUserPurchasesResult
}
