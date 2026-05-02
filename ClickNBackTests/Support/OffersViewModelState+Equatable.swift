//

@testable import ClickNBack

extension OffersViewModel.State: @retroactive Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
             (.empty, .empty):
            return true
        case (.loaded(let lo, let lh), .loaded(let ro, let rh)):
            return lo == ro && lh == rh
        case (.loadingMore(let lo), .loadingMore(let ro)):
            return lo == ro
        case (.refreshing(let lo), .refreshing(let ro)):
            return lo == ro
        case (.error(let le), .error(let re)):
            return le == re
        default:
            return false
        }
    }
}
