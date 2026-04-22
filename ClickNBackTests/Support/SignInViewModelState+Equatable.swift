//

@testable import ClickNBack

extension SignInViewModel.State: @retroactive Equatable {
    public nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.success, .success):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

extension SignInViewModel.Error {
    public nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.badCredentials, .badCredentials),
             (.serverError, .serverError),
             (.timeout, .timeout),
             (.noConnectivity, .noConnectivity):
            return true
        default:
            return false
        }
    }
}
