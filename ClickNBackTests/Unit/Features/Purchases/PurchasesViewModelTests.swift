//

@testable import ClickNBack
import Foundation
import Testing

@MainActor
@Suite("PurchasesViewModel")
struct PurchasesViewModelTests {

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
        #expect(tracker.trackedEventNames == [PurchasesAnalyticsEvent.screenShowed.name])
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
        #expect(tracker.trackedEventNames == [PurchasesAnalyticsEvent.screenShowed.name])
    }

    // MARK: - onAppear – initial load

    @Test
    func onAppear_setsLoadedState_afterSuccessfulFetch() async {
        // Arrange
        let purchases = makePurchases(count: 3)
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: purchases, total: 3)) }
        let sut = makeSUT(purchasesRepository: repository)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(sut.state == .loaded(purchases, hasMore: false))
    }

    @Test
    func onAppear_setsLoadedWithHasMoreTrue_whenMorePagesExist() async {
        // Arrange
        let purchases = makePurchases(count: 20)
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: purchases, total: 42)) }
        let sut = makeSUT(purchasesRepository: repository)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(sut.state == .loaded(purchases, hasMore: true))
    }

    @Test
    func onAppear_setsEmptyState_whenAPIReturnsNoPurchases() async {
        // Arrange
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: [], total: 0)) }
        let sut = makeSUT(purchasesRepository: repository)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(sut.state == .empty)
    }

    @Test
    func onAppear_setsErrorState_onNoConnectivity() async {
        // Arrange
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .failure(.noConnectivity) }
        let sut = makeSUT(purchasesRepository: repository)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(sut.state == .error(.noConnectivity))
    }

    @Test
    func onAppear_setsErrorState_onUnauthorized() async {
        // Arrange
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .failure(.unauthorized) }
        let sut = makeSUT(purchasesRepository: repository)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(sut.state == .error(.unauthorized))
    }

    @Test
    func onAppear_setsErrorState_onServerError() async {
        // Arrange
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .failure(.serverError) }
        let sut = makeSUT(purchasesRepository: repository)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(sut.state == .error(.serverError))
    }

    @Test
    func onAppear_doesNotFetchAgain_whenCalledSecondTime() async {
        // Arrange
        let purchases = makePurchases(count: 3)
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: purchases, total: 3)) }
        let sut = makeSUT(purchasesRepository: repository)

        // Act
        sut.onAppear()
        await Task.yield()
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(repository.fetchUserPurchasesCallCount == 1)
    }

    // MARK: - loadMore

    @Test
    func loadMore_appendsPurchases_onSuccess() async {
        // Arrange
        let initialPurchases = makePurchases(count: 20)
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: initialPurchases, total: 35)) }
        let sut = makeSUT(purchasesRepository: repository)
        sut.onAppear()
        await Task.yield()

        let nextPurchases = makePurchases(count: 15, startIndex: 20)
        repository.fetchUserPurchasesHandler = { _, _ in
            .success(PurchasesPage(
                purchases: nextPurchases,
                pagination: Pagination(offset: 20, limit: 20, total: 35)
            ))
        }

        // Act
        await sut.loadMore()

        // Assert
        let combined = initialPurchases + nextPurchases
        #expect(sut.state == .loaded(combined, hasMore: false))
    }

    @Test
    func loadMore_appendsAllItems_whenMultiplePurchasesReturned() async {
        // Arrange — verifies full list mapping, not just first/last items
        let initialPurchases = makePurchases(count: 20)
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: initialPurchases, total: 60)) }
        let sut = makeSUT(purchasesRepository: repository)
        sut.onAppear()
        await Task.yield()

        let nextPurchases = makePurchases(count: 20, startIndex: 20)
        repository.fetchUserPurchasesHandler = { _, _ in
            .success(PurchasesPage(
                purchases: nextPurchases,
                pagination: Pagination(offset: 20, limit: 20, total: 60)
            ))
        }

        // Act
        await sut.loadMore()

        // Assert
        let combined = initialPurchases + nextPurchases
        #expect(sut.state == .loaded(combined, hasMore: true))
        if case .loaded(let all, _) = sut.state {
            #expect(all.count == 40)
        }
    }

    @Test
    func loadMore_setsHasMoreTrue_whenFurtherPagesExist() async {
        // Arrange
        let initialPurchases = makePurchases(count: 20)
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: initialPurchases, total: 60)) }
        let sut = makeSUT(purchasesRepository: repository)
        sut.onAppear()
        await Task.yield()

        let nextPurchases = makePurchases(count: 20, startIndex: 20)
        repository.fetchUserPurchasesHandler = { _, _ in
            .success(PurchasesPage(
                purchases: nextPurchases,
                pagination: Pagination(offset: 20, limit: 20, total: 60)
            ))
        }

        // Act
        await sut.loadMore()

        // Assert
        let combined = initialPurchases + nextPurchases
        #expect(sut.state == .loaded(combined, hasMore: true))
    }

    @Test
    func loadMore_revertsToLoaded_onError() async {
        // Arrange
        let initialPurchases = makePurchases(count: 20)
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: initialPurchases, total: 42)) }
        let sut = makeSUT(purchasesRepository: repository)
        sut.onAppear()
        await Task.yield()

        repository.fetchUserPurchasesHandler = { _, _ in .failure(.noConnectivity) }

        // Act
        await sut.loadMore()

        // Assert
        #expect(sut.state == .loaded(initialPurchases, hasMore: true))
    }

    @Test
    func loadMore_doesNothing_whenStateIsLoading() async {
        // Arrange
        let repository = MockPurchasesRepository()
        let sut = makeSUT(purchasesRepository: repository)
        // state is .loading (default; onAppear not called)

        // Act
        await sut.loadMore()

        // Assert
        #expect(repository.fetchUserPurchasesCallCount == 0)
    }

    @Test
    func loadMore_doesNothing_whenHasMoreIsFalse() async {
        // Arrange
        let purchases = makePurchases(count: 5)
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: purchases, total: 5)) }
        let sut = makeSUT(purchasesRepository: repository)
        sut.onAppear()
        await Task.yield()
        // state is now .loaded(purchases, hasMore: false)
        let callCountAfterOnAppear = repository.fetchUserPurchasesCallCount

        // Act
        await sut.loadMore()

        // Assert
        #expect(repository.fetchUserPurchasesCallCount == callCountAfterOnAppear)
    }

    @Test
    func loadMore_requestsCorrectNextOffset() async {
        // Arrange
        let initialPurchases = makePurchases(count: 20)
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: initialPurchases, total: 42)) }
        let sut = makeSUT(purchasesRepository: repository)
        sut.onAppear()
        await Task.yield()

        var capturedOffset: Int?
        repository.fetchUserPurchasesHandler = { offset, _ in
            capturedOffset = offset
            return .success(makePurchasesPage(purchases: [], total: 42))
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
        let initialPurchases = makePurchases(count: 3)
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: initialPurchases, total: 3)) }
        let sut = makeSUT(purchasesRepository: repository)
        sut.onAppear()
        await Task.yield()

        let freshPurchases = makePurchases(count: 5)
        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: freshPurchases, total: 5)) }

        // Act
        await sut.refresh()

        // Assert
        #expect(sut.state == .loaded(freshPurchases, hasMore: false))
    }

    @Test
    func refresh_setsEmptyState_whenAPIReturnsNoPurchases() async {
        // Arrange
        let purchases = makePurchases(count: 3)
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: purchases, total: 3)) }
        let sut = makeSUT(purchasesRepository: repository)
        sut.onAppear()
        await Task.yield()

        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: [], total: 0)) }

        // Act
        await sut.refresh()

        // Assert
        #expect(sut.state == .empty)
    }

    @Test
    func refresh_revertsToLoaded_onError_whenDataWasVisible() async {
        // Arrange
        let existingPurchases = makePurchases(count: 3)
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: existingPurchases, total: 3)) }
        let sut = makeSUT(purchasesRepository: repository)
        sut.onAppear()
        await Task.yield()

        repository.fetchUserPurchasesHandler = { _, _ in .failure(.noConnectivity) }

        // Act
        await sut.refresh()

        // Assert — reverts to previous data
        #expect(sut.state == .loaded(existingPurchases, hasMore: true))
    }

    @Test
    func refresh_setsErrorState_onError_afterEmptyState() async {
        // Arrange
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: [], total: 0)) }
        let sut = makeSUT(purchasesRepository: repository)
        sut.onAppear()
        await Task.yield()
        // state == .empty

        repository.fetchUserPurchasesHandler = { _, _ in .failure(.serverError) }

        // Act
        await sut.refresh()

        // Assert
        #expect(sut.state == .error(.serverError))
    }

    @Test
    func refresh_requestsFirstPage() async {
        // Arrange
        let purchases = makePurchases(count: 3)
        let repository = MockPurchasesRepository()
        repository.fetchUserPurchasesHandler = { _, _ in .success(makePurchasesPage(purchases: purchases, total: 3)) }
        let sut = makeSUT(purchasesRepository: repository)
        sut.onAppear()
        await Task.yield()

        var capturedOffset: Int?
        repository.fetchUserPurchasesHandler = { offset, _ in
            capturedOffset = offset
            return .success(makePurchasesPage(purchases: purchases, total: 3))
        }

        // Act
        await sut.refresh()

        // Assert
        #expect(capturedOffset == 0)
    }
}

// MARK: - Test helpers

private extension PurchasesViewModelTests {
    private func makeSUT(
        purchasesRepository: MockPurchasesRepository = MockPurchasesRepository(),
        analyticsTracker: MockAnalyticsTracker = MockAnalyticsTracker()
    ) -> PurchasesViewModel {
        PurchasesViewModel(
            fetchPurchasesUseCase: FetchUserPurchasesUseCase(
                purchasesRepository: purchasesRepository
            ),
            analyticsTracker: analyticsTracker
        )
    }
    
    func makePurchases(count: Int, startIndex: Int = 0) -> [Purchase] {
        (startIndex..<(startIndex + count)).map { index in
            Purchase(
                id: "3E8B7A20-\(String(format: "%04d", index))-4F9C-8D12-1A2B3C4D5E6F",
                merchantName: "Merchant \(index)",
                amount: Decimal(10 + index),
                status: .confirmed,
                cashbackAmount: Decimal(1),
                cashbackStatus: "confirmed",
                createdAt: Date(timeIntervalSince1970: Double(1_746_000_000 + index * 86400))
            )
        }
    }

    func makePurchasesPage(purchases: [Purchase], total: Int) -> PurchasesPage {
        PurchasesPage(
            purchases: purchases,
            pagination: Pagination(offset: 0, limit: 20, total: total)
        )
    }
}
