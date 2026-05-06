//

import Foundation
import Observation

@Observable
final class PurchasesViewModel {

    // MARK: - Dependencies

    private let fetchPurchasesUseCase: FetchUserPurchasesUseCase
    private let analyticsTracker: AnalyticsTracker

    init(
        fetchPurchasesUseCase: FetchUserPurchasesUseCase,
        analyticsTracker: AnalyticsTracker
    ) {
        self.fetchPurchasesUseCase = fetchPurchasesUseCase
        self.analyticsTracker = analyticsTracker
    }

    // MARK: - State

    enum State {
        case loading                                    // initial load, no data yet
        case loaded([Purchase], hasMore: Bool)          // data visible, idle
        case loadingMore([Purchase])                    // paginating (spinner at list bottom)
        case refreshing([Purchase])                     // pull-to-refresh (existing rows still visible)
        case empty                                      // zero purchases returned
        case error(FetchUserPurchasesError)             // network failed
    }

    private(set) var state: State = .loading

    private let pageLimit = 20
    private var hasAppeared = false

    // MARK: - Derived state
    // (used by the view to avoid switch-case branch switching)

    var visiblePurchases: [Purchase]? {
        switch state {
        case .loaded(let purchases, _),
             .loadingMore(let purchases),
             .refreshing(let purchases):
            return purchases
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
        guard case .loaded(let purchases, hasMore: true) = state else { return }
        let nextOffset = purchases.count
        state = .loadingMore(purchases)

        let result = await fetchPurchasesUseCase.execute(offset: nextOffset, limit: pageLimit)
        switch result {
        case .success(let page):
            let combined = purchases + page.purchases
            let moreAvailable = combined.count < page.pagination.total
            state = .loaded(combined, hasMore: moreAvailable)
        case .failure:
            state = .loaded(purchases, hasMore: true)
        }
    }

    func refresh() async {
        switch state {
        case .loaded(let purchases, _):
            state = .refreshing(purchases)
        case .empty, .error:
            state = .loading
        default:
            return
        }

        let result = await fetchPurchasesUseCase.execute(offset: 0, limit: pageLimit)
        switch result {
        case .success(let page):
            if page.purchases.isEmpty {
                state = .empty
            } else {
                let hasMore = page.purchases.count < page.pagination.total
                state = .loaded(page.purchases, hasMore: hasMore)
            }
        case .failure(let error):
            switch state {
            case .refreshing(let purchases):
                state = .loaded(purchases, hasMore: true)
            default:
                state = .error(error)
            }
        }
    }

    // MARK: - Private

    private func initialLoad() async {
        let result = await fetchPurchasesUseCase.execute(offset: 0, limit: pageLimit)
        
        switch result {
        case .success(let page):
            if page.purchases.isEmpty {
                state = .empty
            } else {
                let hasMore = page.purchases.count < page.pagination.total
                state = .loaded(page.purchases, hasMore: hasMore)
            }
        case .failure(let error):
            state = .error(error)
        }
    }

    private func track(_ event: PurchasesAnalyticsEvent) {
        Task {
            await analyticsTracker.track(event)
        }
    }
}
