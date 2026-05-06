//

import Foundation
import Observation

@Observable
final class OffersViewModel {

    // MARK: - Dependencies

    private let fetchOffersUseCase: FetchActiveOffersUseCase
    private let getCachedOffersUseCase: GetCachedOffersUseCase
    private let analyticsTracker: AnalyticsTracker

    init(
        fetchOffersUseCase: FetchActiveOffersUseCase,
        getCachedOffersUseCase: GetCachedOffersUseCase,
        analyticsTracker: AnalyticsTracker
    ) {
        self.fetchOffersUseCase = fetchOffersUseCase
        self.getCachedOffersUseCase = getCachedOffersUseCase
        self.analyticsTracker = analyticsTracker
    }

    // MARK: - State

    enum State {
        case loading                          // first launch, no cache
        case loaded([Offer], hasMore: Bool)   // data visible, idle
        case loadingMore([Offer])             // paginating (spinner at list bottom)
        case refreshing([Offer])              // pull-to-refresh (data still visible)
        case empty                            // zero offers returned, no cache
        case error(FetchActiveOffersError)    // network failed, no cache
    }

    private(set) var state: State = .loading

    private let pageLimit = 20
    private var hasAppeared = false
    private var isInitialLoadInProgress = false

    // MARK: - Derived state 
    // (used by the view to avoid switch-case branch switching)

    var visibleOffers: [Offer]? {
        switch state {
        case .loaded(let offers, _),
            .loadingMore(let offers),
            .refreshing(let offers):
            return offers
        default:
            return nil
        }
    }

    var isLoadingMore: Bool {
        if case .loadingMore = state { return true }
        return false
    }

    var hasMore: Bool {
        switch state {
        case .loaded(_, let hasMore): return hasMore
        case .loadingMore, .refreshing: return true
        default: return false
        }
    }

    // MARK: - API

    func onAppear() {
        guard !hasAppeared else { return }
        hasAppeared = true
        track(.screenShowed)
        Task { await initialLoad() }
    }

    func loadMore() async {
        guard !isInitialLoadInProgress else { return }
        guard case .loaded(let offers, hasMore: true) = state else { return }
        let nextOffset = offers.count
        state = .loadingMore(offers)

        let result = await fetchOffersUseCase.execute(offset: nextOffset, limit: pageLimit)
        switch result {
        case .success(let page):
            let combined = offers + page.offers
            let moreAvailable = combined.count < page.pagination.total
            state = .loaded(combined, hasMore: moreAvailable)
        case .failure:
            state = .loaded(offers, hasMore: true)
        }
    }

    func refresh() async {
        switch state {
        case .loaded(let offers, _):
            state = .refreshing(offers)
        case .empty, .error:
            state = .loading
        default:
            return
        }

        let result = await fetchOffersUseCase.execute(offset: 0, limit: pageLimit)
        switch result {
        case .success(let page):
            if page.offers.isEmpty {
                state = .empty
            } else {
                let hasMore = page.offers.count < page.pagination.total
                state = .loaded(page.offers, hasMore: hasMore)
            }
        case .failure(let error):
            switch state {
            case .refreshing(let offers):
                state = .loaded(offers, hasMore: true)
            default:
                state = .error(error)
            }
        }
    }

    // MARK: - Private

    private func initialLoad() async {
        isInitialLoadInProgress = true
        defer { isInitialLoadInProgress = false }

        if let cached = getCachedOffersUseCase.execute() {
            state = .loaded(cached, hasMore: true)
            let result = await fetchOffersUseCase.execute(offset: 0, limit: pageLimit)
            guard case .success(let page) = result else { return }
            if page.offers.isEmpty {
                state = .empty
            } else {
                let hasMore = page.offers.count < page.pagination.total
                state = .loaded(page.offers, hasMore: hasMore)
            }
        } else {
            let result = await fetchOffersUseCase.execute(offset: 0, limit: pageLimit)
            switch result {
            case .success(let page):
                if page.offers.isEmpty {
                    state = .empty
                } else {
                    let hasMore = page.offers.count < page.pagination.total
                    state = .loaded(page.offers, hasMore: hasMore)
                }
            case .failure(let error):
                state = .error(error)
            }
        }
    }

    private func track(_ event: OffersAnalyticsEvent) {
        Task {
            await analyticsTracker.track(event)
        }
    }
}
