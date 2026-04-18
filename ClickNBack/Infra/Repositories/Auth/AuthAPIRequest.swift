//

import Foundation

enum AuthAPIRequest: APIRequest {
    case login(email: String, password: String)

    var method: HTTPMethod {
        switch self {
        case .login: .POST
        }
    }

    var endpoint: String {
        switch self {
        case .login: "v1/auth/login"
        }
    }

    var headers: [String: String]? {
        nil
    }

    var queryParams: [String: String]? {
        nil
    }

    var body: [String: Any]? {
        switch self {
        case let .login(email, password):
            [
                "email": "\(email)",
                "password": "\(password)"
            ]
        }
    }
}
