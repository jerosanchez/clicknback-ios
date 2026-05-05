import Foundation

public enum PurchasesAPIRequest: APIRequest {
    case listUserPurchases(offset: Int, limit: Int)

    public var method: HTTPMethod {
        switch self {
        case .listUserPurchases: .GET
        }
    }

    public var endpoint: String {
        switch self {
        case .listUserPurchases: "v1/users/me/purchases"
        }
    }

    public var headers: [String: String]? { nil }

    public var queryParams: [String: String]? {
        switch self {
        case let .listUserPurchases(offset, limit):
            [
                "offset": String(offset),
                "limit": String(limit)
            ]
        }
    }

    public var body: [String: Any]? { nil }
}
