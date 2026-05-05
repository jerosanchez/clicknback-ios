public final class FetchUserPurchasesUseCase {
    private let purchasesRepository: PurchasesRepository

    public init(purchasesRepository: PurchasesRepository) {
        self.purchasesRepository = purchasesRepository
    }

    public func execute(offset: Int, limit: Int) async -> FetchUserPurchasesResult {
        await purchasesRepository.fetchUserPurchases(offset: offset, limit: limit)
    }
}
