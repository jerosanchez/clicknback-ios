//

import Foundation

enum APIClientError: Error {
    case invalidURL
    case decodingError
    case apiError(Int, Data?)
    case serverError(Int)
    case requestTimeout
    case noConnection
    case unknownError(Error?)
}
