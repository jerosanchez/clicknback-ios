//

import Foundation

final class MockAPIClient: APIClient {
    
    // MARK: - Spy Properties
    
    var requestHistory: [(endpoint: String, method: String)] = []
    var mockResponses: [String: Any] = [:]
    var mockError: APIClientError?

    init() {}

    // MARK: - API
    
    func request<T: Decodable>(apiRequest: APIRequest) async -> Result<T, APIClientError> {
        requestHistory.append((endpoint: apiRequest.endpoint, method: String(describing: apiRequest.method)))

        if let error = mockError {
            return .failure(error)
        }

        if let response = mockResponses[apiRequest.endpoint] as? T {
            return .success(response)
        }

        let emptyData = Data("{}".utf8)
        let decoded = try! JSONDecoder().decode(T.self, from: emptyData)
        return .success(decoded)
    }

    // MARK: - Testing Helpers

    func setMockResponse(_ response: some Any, for endpoint: String) {
        mockResponses[endpoint] = response
    }

    func setMockError(_ error: APIClientError) {
        mockError = error
    }

    func reset() {
        mockResponses.removeAll()
        mockError = nil
        requestHistory.removeAll()
    }
}
