import ClickNBack
import Testing

@MainActor
@Suite("GetCachedOffersUseCase")
struct GetCachedOffersUseCaseTests {

    @Test
    func execute_returnsNil_onEmptyCache() {
        // Arrange
        let sut = makeSUT()

        // Act
        let result = sut.execute()

        // Assert
        #expect(result == nil)
    }

    @Test
    func execute_returnsOffers_whenCacheHasData() {
        // Arrange
        let cache = MockKeyValueStorage()
        try? cache.set([Offer.mock], forKey: OffersCacheKey.activeOffersFirstPage.rawValue)
        let sut = makeSUT(offersCache: cache)

        // Act
        let result = sut.execute()

        // Assert
        #expect(result == [.mock])
    }

    // MARK: - Helpers

    private func makeSUT(offersCache: KeyValueStorage = MockKeyValueStorage()) -> GetCachedOffersUseCase {
        GetCachedOffersUseCase(offersCache: offersCache)
    }
}
