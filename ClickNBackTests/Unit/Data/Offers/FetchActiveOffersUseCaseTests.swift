import ClickNBack
import Testing

@MainActor
@Suite("FetchActiveOffersUseCase")
struct FetchActiveOffersUseCaseTests {

    @Test
    func execute_returnsPage_onRemoteSuccess() async {
        // Arrange
        let sut = makeSUT()

        // Act
        let result = await sut.execute(offset: 0, limit: 20)

        // Assert
        #expect(result == .success(.mock))
    }

    @Test
    func execute_cachesFirstPageOffers_onSuccessWithOffsetZero() async {
        // Arrange
        let cache = MockKeyValueStorage()
        let sut = makeSUT(offersCache: cache)

        // Act
        _ = await sut.execute(offset: 0, limit: 20)

        // Assert
        let cached = try? cache.get([Offer].self, forKey: OffersCacheKey.activeOffersFirstPage.rawValue)
        #expect(cached == [.mock])
    }

    @Test
    func execute_doesNotCacheOffers_onSuccessWithNonZeroOffset() async {
        // Arrange
        let cache = MockKeyValueStorage()
        let sut = makeSUT(offersCache: cache)

        // Act
        _ = await sut.execute(offset: 20, limit: 20)

        // Assert
        let cached = try? cache.get([Offer].self, forKey: OffersCacheKey.activeOffersFirstPage.rawValue)
        #expect(cached == nil)
    }

    @Test
    func execute_callsRemote_whenCacheHasData() async {
        // Arrange
        let repository = MockOffersRepository()
        let cache = MockKeyValueStorage()
        try? cache.set([Offer.mock], forKey: OffersCacheKey.activeOffersFirstPage.rawValue)
        let sut = makeSUT(offersRepository: repository, offersCache: cache)

        // Act
        _ = await sut.execute(offset: 0, limit: 20)

        // Assert
        #expect(repository.fetchActiveCallCount == 1)
    }

    @Test
    func execute_doesNotCacheOffers_onRemoteError() async {
        // Arrange
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .failure(.serverError) }
        let cache = MockKeyValueStorage()
        let sut = makeSUT(offersRepository: repository, offersCache: cache)

        // Act
        _ = await sut.execute(offset: 0, limit: 20)

        // Assert
        let cached = try? cache.get([Offer].self, forKey: OffersCacheKey.activeOffersFirstPage.rawValue)
        #expect(cached == nil)
    }

    @Test
    func execute_returnsUnauthorizedError_onUnauthorizedError() async {
        // Arrange
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .failure(.unauthorized) }
        let sut = makeSUT(offersRepository: repository)

        // Act
        let result = await sut.execute(offset: 0, limit: 20)

        // Assert
        #expect(result == .failure(.unauthorized))
    }

    @Test
    func execute_returnsServerError_onServerError() async {
        // Arrange
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .failure(.serverError) }
        let sut = makeSUT(offersRepository: repository)

        // Act
        let result = await sut.execute(offset: 0, limit: 20)

        // Assert
        #expect(result == .failure(.serverError))
    }

    @Test
    func execute_returnsNoConnectivityError_onNoConnectivityError() async {
        // Arrange
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .failure(.noConnectivity) }
        let sut = makeSUT(offersRepository: repository)

        // Act
        let result = await sut.execute(offset: 0, limit: 20)

        // Assert
        #expect(result == .failure(.noConnectivity))
    }

    @Test
    func execute_returnsRequestTimeoutError_onRequestTimeoutError() async {
        // Arrange
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .failure(.requestTimeout) }
        let sut = makeSUT(offersRepository: repository)

        // Act
        let result = await sut.execute(offset: 0, limit: 20)

        // Assert
        #expect(result == .failure(.requestTimeout))
    }

    @Test
    func execute_returnsUnexpectedError_onUnexpectedError() async {
        // Arrange
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .failure(.unexpectedError) }
        let sut = makeSUT(offersRepository: repository)

        // Act
        let result = await sut.execute(offset: 0, limit: 20)

        // Assert
        #expect(result == .failure(.unexpectedError))
    }

    // MARK: - Helpers

    private func makeSUT(
        offersRepository: OffersRepository = MockOffersRepository(),
        offersCache: KeyValueStorage = MockKeyValueStorage()
    ) -> FetchActiveOffersUseCase {
        FetchActiveOffersUseCase(offersRepository: offersRepository, offersCache: offersCache)
    }
}
