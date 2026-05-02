//

import Foundation
import Observation

@Observable
class SignInViewModel {

    // MARK: Dependecies

    var loginUseCase: LoginUseCase
    var analyticsTracker: AnalyticsTracker

    var onLoginSuccess: (() -> Void)?

    init(
        loginUseCase: LoginUseCase,
        analyticsTracker: AnalyticsTracker
    ) {
        self.loginUseCase = loginUseCase
        self.analyticsTracker = analyticsTracker
    }

    enum Error: Equatable {
        case badCredentials
        case serverError
        case timeout
        case noConnectivity
    }

    // MARK: State

    enum State: Equatable {
        case idle
        case loading
        case success
        case error(Error)
    }

    var email: String = ""
    var password: String = ""

    private(set) var state: State = .idle

    var isLoading: Bool {
        switch state {
        case .loading: true
        default: false
        }
    }

    // MARK: API

    func onAppear() {
        track(.loginScreenShowed)
    }

    func signInTapped() async {
        state = .loading

        let credentials = LoginCredentials(email: email, password: password)
        let loginResult = await loginUseCase.execute(with: credentials)

        state = loginResult.toState()

        trackLoginResultIfNeeded(for: credentials)

        if case .success = state {
            onLoginSuccess?()
        }
    }

    // MARK: - Helpers

    private func track(_ event: SignInAnalyticsEvents) {
        Task {
            await analyticsTracker.track(event)
        }
    }

    private func trackLoginResultIfNeeded(for credentials: LoginCredentials) {
        switch state {
        case .success:
            track(.loginSucceeded(email: credentials.email))
        default:
            break
        }
    }
}

// MARK: - Helpers

private extension LoginUseCaseResult {
    func toState() -> SignInViewModel.State {
        switch self {
        case .success:
            return .success
        case .badCredentials:
            return .error(.badCredentials)
        case .serverError:
            return .error(.serverError)
        case .requestTimeout:
            return .error(.timeout)
        case .noConnectivity:
            return .error(.noConnectivity)
        case .unexpectedError:
            return .error(.serverError)
        }
    }
}
