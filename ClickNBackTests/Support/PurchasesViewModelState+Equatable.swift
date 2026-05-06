//

@testable import ClickNBack

extension PurchasesViewModel.State: @retroactive Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
             (.empty, .empty):
            return true
        case (.loaded(let lp, let lh), .loaded(let rp, let rh)):
            return lp == rp && lh == rh
        case (.loadingMore(let lp), .loadingMore(let rp)):
            return lp == rp
        case (.refreshing(let lp), .refreshing(let rp)):
            return lp == rp
        case (.error(let le), .error(let re)):
            return le == re
        default:
            return false
        }
    }
}
