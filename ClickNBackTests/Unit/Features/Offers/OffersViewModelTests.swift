//

@testable import ClickNBack
import Testing

@MainActor
@Suite("OffersViewModel")
struct OffersViewModelTests {

    // MARK: - initial state

    @Test
    func state_isLoading_initially() {
        // Arrange / Act
        let sut = makeSUT()

        // Assert
        #expect(sut.state == .loading)
    }

    // MARK: - onAppear – analytics

    @Test
    func onAppear_tracksScreenShowed() async {
        // Arrange
        let tracker = MockAnalyticsTracker()
        let sut = makeSUT(analyticsTracker: tracker)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(tracker.trackedEventNames == [OffersAnalyticsEvent.screenShowed.name])
    }

    @Test
    func onAppear_tracksScreenShowed_onlyOnce_whenCalledMultipleTimes() async {
        // Arrange
        let tracker = MockAnalyticsTracker()
        let sut = makeSUT(analyticsTracker: tracker)

        // Act
        sut.onAppear()
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(tracker.trackedEventNames == [OffersAnalyticsEvent.screenShowed.name])
    }

    // MARK: - onAppear – loading (no cache)

    @Test
    func onAppear_setsLoadedState_afterSuccessfulFetch() async {
        // Arrange
        let offers = makeOffers(count: 3)
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: offers, total: 3)) }
        let sut = makeSUT(offersRepository: repository)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(sut.state == .loaded(offers, hasMore: false))
    }

    @Test
    func onAppear_setsLoadedWithHasMoreTrue_whenMorePagesExist() async {
        // Arrange
        let offers = makeOffers(count: 20)
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: offers, total: 42)) }
        let sut = makeSUT(offersRepository: repository)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(sut.state == .loaded(offers, hasMore: true))
    }

    @Test
    func onAppear_setsEmptyState_whenAPIReturnsNoOffers() async {
        // Arrange
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: [], total: 0)) }
        let sut = makeSUT(offersRepository: repository)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(sut.state == .empty)
    }

    @Test
    func onAppear_setsErrorState_onNoConnectivity() async {
        // Arrange
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .failure(.noConnectivity) }
        let sut = makeSUT(offersRepository: repository)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(sut.state == .error(.noConnectivity))
    }

    @Test
    func onAppear_setsErrorState_onUnauthorized() async {
        // Arrange
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .failure(.unauthorized) }
        let sut = makeSUT(offersRepository: repository)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(sut.state == .error(.unauthorized))
    }

    @Test
    func onAppear_setsErrorState_onServerError() async {
        // Arrange
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .failure(.serverError) }
        let sut = makeSUT(offersRepository: repository)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(sut.state == .error(.serverError))
    }

    // MARK: - onAppear – cache-hit startup

    @Test
    func onAppear_setsLoadedStateFromCache_thenUpdatesAfterBackgroundRefresh() async {
        // Arrange
        let cachedOffers = makeOffers(count: 3)
        let cache = MockKeyValueStorage()
        try? cache.set(cachedOffers, forKey: OffersCacheKey.activeOffersFirstPage.rawValue)

        let freshOffers = makeOffers(count: 5)
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: freshOffers, total: 5)) }
        let sut = makeSUT(offersRepository: repository, offersCache: cache)

        // Act — two yields: one for cache read, one for background refresh
        sut.onAppear()
        await Task.yield()
        await Task.yield()

        // Assert — state reflects fresh data after background refresh
        #expect(sut.state == .loaded(freshOffers, hasMore: false))
    }

    @Test
    func onAppear_callsRemoteOnce_onCacheHit() async {
        // Arrange
        let cachedOffers = makeOffers(count: 3)
        let cache = MockKeyValueStorage()
        try? cache.set(cachedOffers, forKey: OffersCacheKey.activeOffersFirstPage.rawValue)

        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: cachedOffers, total: 3)) }
        let sut = makeSUT(offersRepository: repository, offersCache: cache)

        // Act
        sut.onAppear()
        await Task.yield()
        await Task.yield()

        // Assert
        #expect(repository.fetchActiveCallCount == 1)
    }

    @Test
    func onAppear_doesNotFetchAgain_whenCalledSecondTime() async {
        // Arrange
        let offers = makeOffers(count: 3)
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: offers, total: 3)) }
        let sut = makeSUT(offersRepository: repository)

        // Act
        sut.onAppear()
        await Task.yield()
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(repository.fetchActiveCallCount == 1)
    }

    @Test
    func onAppear_keepsCachedState_whenBackgroundRefreshFails() async {
        // Arrange
        let cachedOffers = makeOffers(count: 3)
        let cache = MockKeyValueStorage()
        try? cache.set(cachedOffers, forKey: OffersCacheKey.activeOffersFirstPage.rawValue)

        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .failure(.noConnectivity) }
        let sut = makeSUT(offersRepository: repository, offersCache: cache)

        // Act
        sut.onAppear()
        await Task.yield()
        await Task.yield()

        // Assert — silent background failure: cached data still shown
        #expect(sut.state == .loaded(cachedOffers, hasMore: true))
    }

    // MARK: - loadMore

    @Test
    func loadMore_appendsOffers_onSuccess() async {
        // Arrange
        let initialOffers = makeOffers(count: 20)
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: initialOffers, total: 35)) }
        let sut = makeSUT(offersRepository: repository)
        sut.onAppear()
        await Task.yield()

        let nextOffers = makeOffers(count: 15, startIndex: 20)
        repository.fetchActiveHandler = { _, _ in
            .success(OffersPage(
                offers: nextOffers,
                pagination: OffersPagination(offset: 20, limit: 20, total: 35)
            ))
        }

        // Act
        await sut.loadMore()

        // Assert
        let combined = initialOffers + nextOffers
        #expect(sut.state == .loaded(combined, hasMore: false))
    }

    @Test
    func loadMore_setsHasMoreTrue_whenFurtherPagesExist() async {
        // Arrange
        let initialOffers = makeOffers(count: 20)
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: initialOffers, total: 60)) }
        let sut = makeSUT(offersRepository: repository)
        sut.onAppear()
        await Task.yield()

        let nextOffers = makeOffers(count: 20, startIndex: 20)
        repository.fetchActiveHandler = { _, _ in
            .success(OffersPage(
                offers: nextOffers,
                pagination: OffersPagination(offset: 20, limit: 20, total: 60)
            ))
        }

        // Act
        await sut.loadMore()

        // Assert
        let combined = initialOffers + nextOffers
        #expect(sut.state == .loaded(combined, hasMore: true))
    }

    @Test
    func loadMore_revertsToLoaded_onError() async {
        // Arrange
        let initialOffers = makeOffers(count: 20)
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: initialOffers, total: 42)) }
        let sut = makeSUT(offersRepository: repository)
        sut.onAppear()
        await Task.yield()

        repository.fetchActiveHandler = { _, _ in .failure(.noConnectivity) }

        // Act
        await sut.loadMore()

        // Assert
        #expect(sut.state == .loaded(initialOffers, hasMore: true))
    }

    @Test
    func loadMore_doesNothing_duringCacheHitBackgroundRefresh() async {
        // Arrange — cache ensures initialLoad takes the background-refresh path
        let cachedOffers = makeOffers(count: 3)
        let cache = MockKeyValueStorage()
        try? cache.set(cachedOffers, forKey: OffersCacheKey.activeOffersFirstPage.rawValue)

        // Use a continuation to pause the background refresh so the in-progress flag stays set
        var resumeContinuation: CheckedContinuation<FetchActiveOffersResult, Never>?
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in
            await withCheckedContinuation { cont in
                resumeContinuation = cont
            }
        }
        let sut = makeSUT(offersRepository: repository, offersCache: cache)

        // Act — one yield lets initialLoad set the flag and suspend at the network call
        sut.onAppear()
        await Task.yield()

        // loadMore should be a no-op while isInitialLoadInProgress == true
        await sut.loadMore()

        // Assert — only the background-refresh call, not an extra one from loadMore
        #expect(repository.fetchActiveCallCount == 1)

        // Clean up — resume the suspended continuation to avoid resource leaks
        resumeContinuation?.resume(returning: .success(makeOffersPage(offers: cachedOffers, total: 3)))
        await Task.yield()
    }

    @Test
    func loadMore_doesNothing_whenStateIsLoading() async {
        // Arrange
        let repository = MockOffersRepository()
        let sut = makeSUT(offersRepository: repository)
        // state is .loading (default; onAppear not called)

        // Act
        await sut.loadMore()

        // Assert
        #expect(repository.fetchActiveCallCount == 0)
    }

    @Test
    func loadMore_doesNothing_whenHasMoreIsFalse() async {
        // Arrange
        let offers = makeOffers(count: 5)
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: offers, total: 5)) }
        let sut = makeSUT(offersRepository: repository)
        sut.onAppear()
        await Task.yield()
        // state is now .loaded(offers, hasMore: false)
        let callCountAfterOnAppear = repository.fetchActiveCallCount

        // Act
        await sut.loadMore()

        // Assert
        #expect(repository.fetchActiveCallCount == callCountAfterOnAppear)
    }

    @Test
    func loadMore_requestsCorrectNextOffset() async {
        // Arrange
        let initialOffers = makeOffers(count: 20)
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: initialOffers, total: 42)) }
        let sut = makeSUT(offersRepository: repository)
        sut.onAppear()
        await Task.yield()

        var capturedOffset: Int?
        repository.fetchActiveHandler = { offset, _ in
            capturedOffset = offset
            return .success(makeOffersPage(offers: [], total: 42))
        }

        // Act
        await sut.loadMore()

        // Assert
        #expect(capturedOffset == 20)
    }

    // MARK: - refresh

    @Test
    func refresh_setsLoadedState_afterSuccessfulFetch() async {
        // Arrange
        let initialOffers = makeOffers(count: 3)
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: initialOffers, total: 3)) }
        let sut = makeSUT(offersRepository: repository)
        sut.onAppear()
        await Task.yield()

        let freshOffers = makeOffers(count: 5)
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: freshOffers, total: 5)) }

        // Act
        await sut.refresh()

        // Assert
        #expect(sut.state == .loaded(freshOffers, hasMore: false))
    }

    @Test
    func refresh_setsEmptyState_whenAPIReturnsNoOffers() async {
        // Arrange
        let offers = makeOffers(count: 3)
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: offers, total: 3)) }
        let sut = makeSUT(offersRepository: repository)
        sut.onAppear()
        await Task.yield()

        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: [], total: 0)) }

        // Act
        await sut.refresh()

        // Assert
        #expect(sut.state == .empty)
    }

    @Test
    func refresh_revertsToLoaded_onError_whenDataWasVisible() async {
        // Arrange
        let existingOffers = makeOffers(count: 3)
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: existingOffers, total: 3)) }
        let sut = makeSUT(offersRepository: repository)
        sut.onAppear()
        await Task.yield()

        repository.fetchActiveHandler = { _, _ in .failure(.noConnectivity) }

        // Act
        await sut.refresh()

        // Assert — reverts to previous data
        #expect(sut.state == .loaded(existingOffers, hasMore: true))
    }

    @Test
    func refresh_setsErrorState_onError_afterEmptyState() async {
        // Arrange
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: [], total: 0)) }
        let sut = makeSUT(offersRepository: repository)
        sut.onAppear()
        await Task.yield()
        // state == .empty

        repository.fetchActiveHandler = { _, _ in .failure(.serverError) }

        // Act
        await sut.refresh()

        // Assert
        #expect(sut.state == .error(.serverError))
    }

    @Test
    func refresh_requestsFirstPage() async {
        // Arrange
        let offers = makeOffers(count: 3)
        let repository = MockOffersRepository()
        repository.fetchActiveHandler = { _, _ in .success(makeOffersPage(offers: offers, total: 3)) }
        let sut = makeSUT(offersRepository: repository)
        sut.onAppear()
        await Task.yield()

        var capturedOffset: Int?
        repository.fetchActiveHandler = { offset, _ in
            capturedOffset = offset
            return .success(makeOffersPage(offers: offers, total: 3))
        }

        // Act
        await sut.refresh()

        // Assert
        #expect(capturedOffset == 0)
    }

    // MARK: - Factories

    private func makeSUT(
        offersRepository: MockOffersRepository = MockOffersRepository(),
        offersCache: MockKeyValueStorage = MockKeyValueStorage(),
        analyticsTracker: MockAnalyticsTracker = MockAnalyticsTracker()
    ) -> OffersViewModel {
        OffersViewModel(
            fetchOffersUseCase: FetchActiveOffersUseCase(
                offersRepository: offersRepository,
                offersCache: offersCache
            ),
            getCachedOffersUseCase: GetCachedOffersUseCase(
                offersCache: offersCache
            ),
            analyticsTracker: analyticsTracker
        )
    }
}

// MARK: - Test helpers

private extension OffersViewModelTests {
    func makeOffers(count: Int, startIndex: Int = 0) -> [Offer] {
        (startIndex..<(startIndex + count)).map { index in
            Offer(
                id: "3E8B7A20-\(String(format: "%04d", index))-4F9C-8D12-1A2B3C4D5E6F",
                merchantName: "Merchant \(index)",
                cashbackType: .percent,
                cashbackValue: 10.0,
                monthlyCap: 50.0,
                startDate: "2026-01-01",
                endDate: "2026-12-31"
            )
        }
    }

    func makeOffersPage(offers: [Offer], total: Int) -> OffersPage {
        OffersPage(
            offers: offers,
            pagination: OffersPagination(offset: 0, limit: 20, total: total)
        )
    }
}
