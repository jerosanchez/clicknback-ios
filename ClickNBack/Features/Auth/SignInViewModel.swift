//

import Foundation
import Observation

@Observable
class SignInViewModel {
    enum State {
        case idle
        case loading
        case success
        case failure
        case timeout
        case noInternet
        case error
    }

    var email: String = ""
    var password: String = ""

    private(set) var state: State = .idle
}
