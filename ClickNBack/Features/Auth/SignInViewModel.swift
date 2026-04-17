//

import Foundation
import Observation

@Observable
class SignInViewModel {
    
    // MARK: Dependecies
    
    var loginUseCase: LoginUseCase
    
    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }
    
    // MARK: State
    
    enum State {
        case idle
        case loading
        case success
        case badCredentials
        case serverError
        case timeout
        case noConnectivity
    }

    var email: String = ""
    var password: String = ""

    private(set) var state: State = .idle
    
    // MARK: API
    
    func login() async {
        state = .loading

        let credentials = LoginCredentials(email: email, password: password)
        let loginResult = await loginUseCase.execute(with: credentials)

        state = loginResult.toState()
        print("Login result: \(state)") // Debug log
    }
}

// MARK: - Helpers

private extension LoginUseCaseResult {
    func toState() -> SignInViewModel.State {
        switch self {
        case .success:
            return .success
        case .badCredentials:
            return .badCredentials
        case .serverError:
            return .serverError
        case .requestTimeout:
            return .timeout
        case .noConnectivity:
            return .noConnectivity
        case .unexpectedError:
            return .serverError
        }
    }
}
