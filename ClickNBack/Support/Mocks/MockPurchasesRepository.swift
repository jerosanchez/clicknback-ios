public typealias FetchUserPurchasesHandler = (Int, Int) async -> FetchUserPurchasesResult

public final class MockPurchasesRepository: PurchasesRepository {
    public private(set) var fetchUserPurchasesCallCount = 0
    public var fetchUserPurchasesHandler: FetchUserPurchasesHandler?

    public init() {}

    public func fetchUserPurchases(offset: Int, limit: Int) async -> FetchUserPurchasesResult {
        fetchUserPurchasesCallCount += 1
        return await fetchUserPurchasesHandler?(offset, limit) ?? .success(.mock)
    }
}
