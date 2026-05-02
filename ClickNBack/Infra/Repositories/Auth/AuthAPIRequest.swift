//

import Foundation

public enum AuthAPIRequest: APIRequest {
    case login(email: String, password: String)
    case refresh(token: String)

    public var method: HTTPMethod {
        switch self {
        case .login: .POST
        case .refresh: .POST
        }
    }

    public var endpoint: String {
        switch self {
        case .login: "v1/auth/login"
        case .refresh: "v1/auth/refresh"
        }
    }

    public var headers: [String: String]? {
        nil
    }

    public var queryParams: [String: String]? {
        nil
    }

    public var body: [String: Any]? {
        switch self {
        case let .login(email, password):
            [
                "email": "\(email)",
                "password": "\(password)"
            ]
        case let .refresh(token):
            ["refresh_token": token]
        }
    }
}
