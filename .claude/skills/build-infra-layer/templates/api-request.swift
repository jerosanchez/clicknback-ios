// MARK: - API Request Enum
// File: ClickNBack/Infra/Repositories/<Feature>/<Feature>APIRequest.swift

import Foundation

public enum <Feature>APIRequest: APIRequest {
    case list<Models>(offset: Int, limit: Int)
    // Add one case per operation, e.g.:
    // case fetch<Model>(id: String)
    // case create<Model>(body: Create<Model>Body)

    public var method: HTTPMethod {
        switch self {
        case .list<Models>: .GET
        // case .create<Model>: .POST
        }
    }

    public var endpoint: String {
        switch self {
        case .list<Models>: "v1/<resource>"
        // case .fetch<Model>(let id): "v1/<resource>/\(id)"
        }
    }

    // Return nil unless the request needs custom headers beyond what the API client injects.
    public var headers: [String: String]? { nil }

    public var queryParams: [String: String]? {
        switch self {
        case let .list<Models>(offset, limit):
            [
                "offset": String(offset),
                "limit": String(limit)
            ]
        // GET requests with no query params: return nil
        }
    }

    // Return nil for GET requests; supply a [String: Any] literal for POST/PUT.
    public var body: [String: Any]? { nil }
}
