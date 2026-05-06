// MARK: - ViewModel State Equatable Support
// File: ClickNBackTests/Support/<Feature>ViewModelState+Equatable.swift
//
// Required for #expect(sut.state == .loaded(...)) assertions.
// Uses @retroactive to conform a non-public type from the main module.

@testable import ClickNBack

extension <Screen>ViewModel.State: @retroactive Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
             (.empty, .empty):
            return true
        case (.loaded(let li, let lh), .loaded(let ri, let rh)):
            return li == ri && lh == rh
        case (.loadingMore(let l), .loadingMore(let r)):
            return l == r
        case (.refreshing(let l), .refreshing(let r)):
            return l == r
        case (.error(let l), .error(let r)):
            return l == r
        default:
            return false
        }
    }
}

// NOTE: If the domain model (e.g. Purchase) has a synthesized Equatable from
// `struct <Model>: Equatable`, it will be @MainActor-isolated (project-wide
// SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor), causing a compile error:
//   "main actor-isolated conformance of '<Model>' to 'Equatable' cannot be used
//    in nonisolated context"
// Fix: replace the synthesized conformance with an explicit nonisolated extension:
//
//   extension <Model>: Equatable {
//       public nonisolated static func == (lhs: <Model>, rhs: <Model>) -> Bool {
//           lhs.id == rhs.id && lhs.fieldA == rhs.fieldA && ...
//       }
//   }
//
// See ClickNBack/Data/Offers/Offer.swift for a working example.

// MARK: - ViewModel Tests
// File: ClickNBackTests/Unit/Features/<Feature>/<Screen>ViewModelTests.swift

@testable import ClickNBack
import Foundation
import Testing

@MainActor
@Suite("<Screen>ViewModel")
struct <Screen>ViewModelTests {

    // MARK: - initial state

    @Test
    func state_isLoading_initially() {
        let sut = makeSUT()
        #expect(sut.state == .loading)
    }

    // MARK: - onAppear – analytics

    @Test
    func onAppear_tracksScreenShowed() async {
        let tracker = MockAnalyticsTracker()
        let sut = makeSUT(analyticsTracker: tracker)
        sut.onAppear()
        await Task.yield()
        #expect(tracker.trackedEventNames == [<Feature>AnalyticsEvent.screenShowed.name])
    }

    @Test
    func onAppear_tracksScreenShowed_onlyOnce_whenCalledMultipleTimes() async {
        let tracker = MockAnalyticsTracker()
        let sut = makeSUT(analyticsTracker: tracker)
        sut.onAppear()
        sut.onAppear()
        await Task.yield()
        #expect(tracker.trackedEventNames == [<Feature>AnalyticsEvent.screenShowed.name])
    }

    // MARK: - onAppear – loading

    @Test
    func onAppear_setsLoadedState_afterSuccessfulFetch() async {
        // Arrange
        let items = makeItems(count: 3)
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .success(makePage(items: items, total: 3)) }
        let sut = makeSUT(repository: repository)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(sut.state == .loaded(items, hasMore: false))
    }

    @Test
    func onAppear_setsLoadedWithHasMoreTrue_whenMorePagesExist() async {
        // Arrange
        let items = makeItems(count: 20)
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .success(makePage(items: items, total: 42)) }
        let sut = makeSUT(repository: repository)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(sut.state == .loaded(items, hasMore: true))
    }

    @Test
    func onAppear_setsEmptyState_whenAPIReturnsNoItems() async {
        // Arrange
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .success(makePage(items: [], total: 0)) }
        let sut = makeSUT(repository: repository)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(sut.state == .empty)
    }

    @Test
    func onAppear_setsErrorState_onNoConnectivity() async {
        // Arrange
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .failure(.noConnectivity) }
        let sut = makeSUT(repository: repository)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(sut.state == .error(.noConnectivity))
    }

    // Add one test per remaining error case: .unauthorized, .serverError, etc.

    @Test
    func onAppear_doesNotFetchAgain_whenCalledSecondTime() async {
        // Arrange
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .success(makePage(items: makeItems(count: 3), total: 3)) }
        let sut = makeSUT(repository: repository)

        // Act
        sut.onAppear()
        await Task.yield()
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(repository.fetch<Models>CallCount == 1)
    }

    // MARK: - loadMore

    @Test
    func loadMore_appendsItems_onSuccess() async {
        // Arrange
        let initial = makeItems(count: 20)
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .success(makePage(items: initial, total: 35)) }
        let sut = makeSUT(repository: repository)
        sut.onAppear()
        await Task.yield()

        let next = makeItems(count: 15, startIndex: 20)
        repository.fetch<Models>Handler = { _, _ in
            .success(<Feature>sPage(
                <models>: next,
                pagination: Pagination(offset: 20, limit: 20, total: 35)
            ))
        }

        // Act
        await sut.loadMore()

        // Assert
        #expect(sut.state == .loaded(initial + next, hasMore: false))
    }

    @Test
    func loadMore_appendsAllItems_whenMultipleItemsReturned() async {
        // Arrange — verifies full list mapping (not just first/last items)
        let initial = makeItems(count: 20)
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .success(makePage(items: initial, total: 60)) }
        let sut = makeSUT(repository: repository)
        sut.onAppear()
        await Task.yield()

        let next = makeItems(count: 20, startIndex: 20)
        repository.fetch<Models>Handler = { _, _ in
            .success(<Feature>sPage(
                <models>: next,
                pagination: Pagination(offset: 20, limit: 20, total: 60)
            ))
        }

        // Act
        await sut.loadMore()

        // Assert
        if case .loaded(let all, _) = sut.state {
            #expect(all.count == 40)
        }
    }

    @Test
    func loadMore_revertsToLoaded_onError() async {
        // Arrange
        let initial = makeItems(count: 20)
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .success(makePage(items: initial, total: 42)) }
        let sut = makeSUT(repository: repository)
        sut.onAppear()
        await Task.yield()

        repository.fetch<Models>Handler = { _, _ in .failure(.noConnectivity) }

        // Act
        await sut.loadMore()

        // Assert
        #expect(sut.state == .loaded(initial, hasMore: true))
    }

    @Test
    func loadMore_doesNothing_whenStateIsLoading() async {
        let repository = Mock<Feature>Repository()
        let sut = makeSUT(repository: repository)
        await sut.loadMore()
        #expect(repository.fetch<Models>CallCount == 0)
    }

    @Test
    func loadMore_doesNothing_whenHasMoreIsFalse() async {
        // Arrange
        let items = makeItems(count: 5)
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .success(makePage(items: items, total: 5)) }
        let sut = makeSUT(repository: repository)
        sut.onAppear()
        await Task.yield()
        let countAfterOnAppear = repository.fetch<Models>CallCount

        // Act
        await sut.loadMore()

        // Assert
        #expect(repository.fetch<Models>CallCount == countAfterOnAppear)
    }

    @Test
    func loadMore_requestsCorrectNextOffset() async {
        // Arrange
        let initial = makeItems(count: 20)
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .success(makePage(items: initial, total: 42)) }
        let sut = makeSUT(repository: repository)
        sut.onAppear()
        await Task.yield()

        var capturedOffset: Int?
        repository.fetch<Models>Handler = { offset, _ in
            capturedOffset = offset
            return .success(makePage(items: [], total: 42))
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
        let initial = makeItems(count: 3)
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .success(makePage(items: initial, total: 3)) }
        let sut = makeSUT(repository: repository)
        sut.onAppear()
        await Task.yield()

        let fresh = makeItems(count: 5)
        repository.fetch<Models>Handler = { _, _ in .success(makePage(items: fresh, total: 5)) }

        // Act
        await sut.refresh()

        // Assert
        #expect(sut.state == .loaded(fresh, hasMore: false))
    }

    @Test
    func refresh_setsEmptyState_whenAPIReturnsNoItems() async {
        // Arrange
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .success(makePage(items: makeItems(count: 3), total: 3)) }
        let sut = makeSUT(repository: repository)
        sut.onAppear()
        await Task.yield()

        repository.fetch<Models>Handler = { _, _ in .success(makePage(items: [], total: 0)) }

        // Act
        await sut.refresh()

        // Assert
        #expect(sut.state == .empty)
    }

    @Test
    func refresh_revertsToLoaded_onError_whenDataWasVisible() async {
        // Arrange
        let existing = makeItems(count: 3)
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .success(makePage(items: existing, total: 3)) }
        let sut = makeSUT(repository: repository)
        sut.onAppear()
        await Task.yield()

        repository.fetch<Models>Handler = { _, _ in .failure(.noConnectivity) }

        // Act
        await sut.refresh()

        // Assert — silent failure: restores previous data
        #expect(sut.state == .loaded(existing, hasMore: true))
    }

    @Test
    func refresh_setsErrorState_onError_afterEmptyState() async {
        // Arrange
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .success(makePage(items: [], total: 0)) }
        let sut = makeSUT(repository: repository)
        sut.onAppear()
        await Task.yield()
        // state == .empty

        repository.fetch<Models>Handler = { _, _ in .failure(.serverError) }

        // Act
        await sut.refresh()

        // Assert
        #expect(sut.state == .error(.serverError))
    }

    @Test
    func refresh_requestsFirstPage() async {
        // Arrange
        let items = makeItems(count: 3)
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .success(makePage(items: items, total: 3)) }
        let sut = makeSUT(repository: repository)
        sut.onAppear()
        await Task.yield()

        var capturedOffset: Int?
        repository.fetch<Models>Handler = { offset, _ in
            capturedOffset = offset
            return .success(makePage(items: items, total: 3))
        }

        // Act
        await sut.refresh()

        // Assert
        #expect(capturedOffset == 0)
    }

    // MARK: - Factories

    private func makeSUT(
        repository: Mock<Feature>Repository = Mock<Feature>Repository(),
        analyticsTracker: MockAnalyticsTracker = MockAnalyticsTracker()
    ) -> <Screen>ViewModel {
        <Screen>ViewModel(
            fetch<Models>UseCase: Fetch<Model>UseCase(
                <feature>Repository: repository
            ),
            analyticsTracker: analyticsTracker
        )
    }
}

// MARK: - Test helpers

private extension <Screen>ViewModelTests {
    func makeItems(count: Int, startIndex: Int = 0) -> [<Model>] {
        (startIndex..<(startIndex + count)).map { index in
            <Model>(
                id: "3E8B7A20-\(String(format: "%04d", index))-4F9C-8D12-1A2B3C4D5E6F",
                // fill remaining fields with index-varied values
            )
        }
    }

    func makePage(items: [<Model>], total: Int) -> <Feature>sPage {
        <Feature>sPage(
            <models>: items,
            pagination: Pagination(offset: 0, limit: 20, total: total)
        )
    }
}

// MARK: - Analytics Event Tests
// File: ClickNBackTests/Unit/Features/<Feature>/<Feature>AnalyticsEventTests.swift

@testable import ClickNBack
import Testing

@MainActor
@Suite("<Feature>AnalyticsEvent")
struct <Feature>AnalyticsEventTests {

    @Test
    func name_returns<Feature>ScreenShowed_forScreenShowedCase() {
        let sut = <Feature>AnalyticsEvent.screenShowed
        #expect(sut.name == "<feature>-screen-showed")
    }

    @Test
    func properties_isEmpty_forScreenShowedCase() {
        let sut = <Feature>AnalyticsEvent.screenShowed
        #expect(sut.properties.isEmpty)
    }
}
