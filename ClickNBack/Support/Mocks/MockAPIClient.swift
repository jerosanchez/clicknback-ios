//

import Foundation

public final class MockAPIClient: APIClient {

    // MARK: - Spy Properties

    public var requestHistory: [(endpoint: String, method: String)] = []
    public var mockResponses: [String: Any] = [:]
    public var mockError: APIClientError?
    /// Sequential error queue. Each call dequeues one entry. `nil` means fall through to the
    /// success path (mockResponses); a non-nil value returns that error for that call.
    public var errorQueue: [APIClientError?] = []

    public init() {}

    // MARK: - API

    public func request<T: Decodable>(apiRequest: APIRequest) async -> Result<T, APIClientError> {
        requestHistory.append((endpoint: apiRequest.endpoint, method: String(describing: apiRequest.method)))

        if !errorQueue.isEmpty {
            let queued = errorQueue.removeFirst()
            if let error = queued { return .failure(error) }
            // nil → fall through to success path
        } else if let error = mockError {
            return .failure(error)
        }

        if let response = mockResponses[apiRequest.endpoint] as? T {
            return .success(response)
        }

        let emptyData = Data("{}".utf8)
        guard let decoded = try? JSONDecoder().decode(T.self, from: emptyData) else {
            return .failure(.decodingError)
        }
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
        errorQueue.removeAll()
    }
}
