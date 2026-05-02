//

import Foundation

public struct MockAPIRequest: APIRequest {
    public let method: HTTPMethod
    public let endpoint: String
    public let headers: [String: String]?
    public let queryParams: [String: String]?
    public let body: [String: Any]?

    public init(
        endpoint: String,
        method: HTTPMethod = .GET,
        headers: [String: String]? = nil,
        queryParams: [String: String]? = nil,
        body: [String: Any]? = nil
    ) {
        self.endpoint = endpoint
        self.method = method
        self.headers = headers
        self.queryParams = queryParams
        self.body = body
    }
}
