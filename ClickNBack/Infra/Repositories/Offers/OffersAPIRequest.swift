import Foundation

public enum OffersAPIRequest: APIRequest {
    case listActive(offset: Int, limit: Int)

    public var method: HTTPMethod {
        switch self {
        case .listActive: .GET
        }
    }

    public var endpoint: String {
        switch self {
        case .listActive: "v1/offers/active"
        }
    }

    public var headers: [String: String]? { nil }

    public var queryParams: [String: String]? {
        switch self {
        case let .listActive(offset, limit):
            [
                "offset": String(offset),
                "limit": String(limit)
            ]
        }
    }

    public var body: [String: Any]? { nil }
}
