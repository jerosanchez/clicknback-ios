//

import Foundation

public final class MockAPIClient: APIClient {
    
    // MARK: - Spy Properties
    
    public var requestHistory: [(endpoint: String, method: String)] = []
    public var mockResponses: [String: Any] = [:]
    public var mockError: APIClientError?

    public init() {}

    // MARK: - API
    
    public func request<T: Decodable>(apiRequest: APIRequest) async -> Result<T, APIClientError> {
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

    public func setMockResponse(_ response: some Any, for endpoint: String) {
        mockResponses[endpoint] = response
    }

    public func setMockError(_ error: APIClientError) {
        mockError = error
    }

    public func reset() {
        mockResponses.removeAll()
        mockError = nil
        requestHistory.removeAll()
    }
}
