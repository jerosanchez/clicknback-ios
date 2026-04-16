//

import Foundation

protocol APIRequest {
    var method: HTTPMethod { get }
    var endpoint: String { get }
    var headers: [String: String]? { get }
    var queryParams: [String: String]? { get }
    var body: [String: Any]? { get }
}
