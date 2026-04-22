public final class FetchActiveOffersUseCase {
    private let offersRepository: OffersRepository
    private let offersCache: KeyValueStorage

    public init(
        offersRepository: OffersRepository,
        offersCache: KeyValueStorage
    ) {
        self.offersRepository = offersRepository
        self.offersCache = offersCache
    }

    public func execute(offset: Int, limit: Int) async -> FetchActiveOffersResult {
        let result = await offersRepository.fetchActive(offset: offset, limit: limit)

        if case .success(let page) = result, offset == 0 {
            try? offersCache.set(page.offers, forKey: OffersCacheKey.activeOffersFirstPage.rawValue)
        }

        return result
    }
}
