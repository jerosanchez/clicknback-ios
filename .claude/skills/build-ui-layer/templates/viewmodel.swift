// MARK: - ViewModel
// File: ClickNBack/Features/<Feature>/<Screen>ViewModel.swift

import Foundation
import Observation

@Observable
final class <Screen>ViewModel {

    // MARK: - Dependencies

    private let fetch<Models>UseCase: Fetch<Model>UseCase
    private let analyticsTracker: AnalyticsTracker

    init(
        fetch<Models>UseCase: Fetch<Model>UseCase,
        analyticsTracker: AnalyticsTracker
    ) {
        self.fetch<Models>UseCase = fetch<Models>UseCase
        self.analyticsTracker = analyticsTracker
    }

    // MARK: - State

    enum State {
        case loading                               // initial load, no data yet
        case loaded([<Model>], hasMore: Bool)      // data visible, idle
        case loadingMore([<Model>])                // paginating (spinner at list bottom)
        case refreshing([<Model>])                 // pull-to-refresh (existing rows still visible)
        case empty                                 // zero items returned
        case error(Fetch<Model>Error)              // network failed
    }

    private(set) var state: State = .loading

    private let pageLimit = 20
    private var hasAppeared = false

    // MARK: - Derived state
    // Used by the view to keep a single structural identity for the ScrollView,
    // preventing scroll-position resets during .loaded → .loadingMore → .loaded transitions.

    var visible<Models>: [<Model>]? {
        switch state {
        case .loaded(let items, _),
             .loadingMore(let items),
             .refreshing(let items):
            return items
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

    /// Called once when the screen first appears (guarded by `hasAppeared`).
    func onAppear() {
        guard !hasAppeared else { return }
        hasAppeared = true
        track(.screenShowed)
        Task { await initialLoad() }
    }

    /// Loads the next page. No-op unless state is `.loaded(_, hasMore: true)`.
    func loadMore() async {
        guard case .loaded(let items, hasMore: true) = state else { return }
        let nextOffset = items.count
        state = .loadingMore(items)

        let result = await fetch<Models>UseCase.execute(offset: nextOffset, limit: pageLimit)
        switch result {
        case .success(let page):
            let combined = items + page.<models>
            let moreAvailable = combined.count < page.pagination.total
            state = .loaded(combined, hasMore: moreAvailable)
        case .failure:
            state = .loaded(items, hasMore: true)
        }
    }

    /// Resets and re-fetches from page 0. Keeps existing rows visible during the request.
    func refresh() async {
        switch state {
        case .loaded(let items, _):
            state = .refreshing(items)
        case .empty, .error:
            state = .loading
        default:
            return
        }

        let result = await fetch<Models>UseCase.execute(offset: 0, limit: pageLimit)
        switch result {
        case .success(let page):
            if page.<models>.isEmpty {
                state = .empty
            } else {
                let hasMore = page.<models>.count < page.pagination.total
                state = .loaded(page.<models>, hasMore: hasMore)
            }
        case .failure(let error):
            switch state {
            case .refreshing(let items):
                state = .loaded(items, hasMore: true)    // silent failure: restore previous data
            default:
                state = .error(error)
            }
        }
    }

    // MARK: - Private

    private func initialLoad() async {
        let result = await fetch<Models>UseCase.execute(offset: 0, limit: pageLimit)
        switch result {
        case .success(let page):
            if page.<models>.isEmpty {
                state = .empty
            } else {
                let hasMore = page.<models>.count < page.pagination.total
                state = .loaded(page.<models>, hasMore: hasMore)
            }
        case .failure(let error):
            state = .error(error)
        }
    }

    private func track(_ event: <Feature>AnalyticsEvent) {
        Task {
            await analyticsTracker.track(event)
        }
    }
}
