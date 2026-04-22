public final class GetCachedOffersUseCase {
    private let offersCache: KeyValueStorage

    public init(offersCache: KeyValueStorage) {
        self.offersCache = offersCache
    }

    public func execute() -> [Offer]? {
        try? offersCache.get([Offer].self, forKey: OffersCacheKey.activeOffersFirstPage.rawValue)
    }
}
