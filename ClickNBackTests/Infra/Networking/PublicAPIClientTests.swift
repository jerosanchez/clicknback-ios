//

import ClickNBack
import Foundation
import Testing

@MainActor
@Suite("PublicAPIClient")
struct PublicAPIClientTests {
    let baseURL = URL(string: "https://api.example.com")!

    @Test
    func request_returnsDecodedData_onStatusCodesInSuccessRange() async {
        for statusCode in [200, 250, 299] {
            // Arrange
            let testModel = TestModel(id: 1, name: "Test")
            MockURLProtocol.stub(data: encoded(testModel), statusCode: statusCode)
            let sut = makeSUT()
            let apiRequest = MockAPIRequest(endpoint: "/items")

            // Act
            let result: Result<TestModel, APIClientError> = await sut.request(apiRequest: apiRequest)

            // Assert
            guard case .success(let model) = result else {
                #expect(Bool(false), "Expected success for status \(statusCode)")
                return
            }
            #expect(model.id == testModel.id)
            #expect(model.name == testModel.name)
        }
    }

    @Test
    func request_returnsDecodingError_onInvalidJSON() async {
        // Arrange
        MockURLProtocol.stub(data: "not valid json".data(using: .utf8)!, statusCode: 200)
        let sut = makeSUT()
        let apiRequest = MockAPIRequest(endpoint: "/items")

        // Act
        let result: Result<TestModel, APIClientError> = await sut.request(apiRequest: apiRequest)

        // Assert
        guard case .failure(.decodingError) = result else {
            #expect(Bool(false), "Expected decodingError")
            return
        }
    }

    @Test
    func request_returnsAPIError_onStatusCodesInClientErrorRange() async {
        for statusCode in [400, 450, 499] {
            // Arrange
            let errorData = "Error response".data(using: .utf8)!
            MockURLProtocol.stub(data: errorData, statusCode: statusCode)
            let sut = makeSUT()
            let apiRequest = MockAPIRequest(endpoint: "/items")

            // Act
            let result: Result<TestModel, APIClientError> = await sut.request(apiRequest: apiRequest)

            // Assert
            guard case .failure(.apiError(let returnedStatusCode, let returnedData)) = result else {
                #expect(Bool(false), "Expected apiError for status \(statusCode)")
                return
            }
            #expect(returnedStatusCode == statusCode)
            #expect(returnedData == errorData)
        }
    }

    @Test
    func request_returnsServerError_onStatusCodesInServerErrorRange() async {
        for statusCode in [500, 502, 599] {
            // Arrange
            MockURLProtocol.stub(data: Data(), statusCode: statusCode)
            let sut = makeSUT()
            let apiRequest = MockAPIRequest(endpoint: "/items")

            // Act
            let result: Result<TestModel, APIClientError> = await sut.request(apiRequest: apiRequest)

            // Assert
            guard case .failure(.serverError(let returnedStatusCode)) = result else {
                #expect(Bool(false), "Expected serverError for status \(statusCode)")
                return
            }
            #expect(returnedStatusCode == statusCode)
        }
    }

    @Test
    func request_returnsUnknownError_onUnexpectedStatusCode() async {
        for statusCode in [199, 600, 1000] {
            // Arrange
            MockURLProtocol.stub(data: Data(), statusCode: statusCode)
            let sut = makeSUT()
            let apiRequest = MockAPIRequest(endpoint: "/items")

            // Act
            let result: Result<TestModel, APIClientError> = await sut.request(apiRequest: apiRequest)

            // Assert
            guard case .failure(.unknownError) = result else {
                #expect(Bool(false), "Expected unknownError for status \(statusCode)")
                return
            }
        }
    }

    @Test
    func request_returnsNoConnection_onNotConnectedError() async {
        // Arrange
        MockURLProtocol.stub(error: URLError(.notConnectedToInternet))
        let sut = makeSUT()
        let apiRequest = MockAPIRequest(endpoint: "/items")

        // Act
        let result: Result<TestModel, APIClientError> = await sut.request(apiRequest: apiRequest)

        // Assert
        guard case .failure(.noConnection) = result else {
            #expect(Bool(false), "Expected noConnection error")
            return
        }
    }

    @Test
    func request_returnsNoConnection_onNetworkConnectionLostError() async {
        // Arrange
        MockURLProtocol.stub(error: URLError(.networkConnectionLost))
        let sut = makeSUT()
        let apiRequest = MockAPIRequest(endpoint: "/items")

        // Act
        let result: Result<TestModel, APIClientError> = await sut.request(apiRequest: apiRequest)

        // Assert
        guard case .failure(.noConnection) = result else {
            #expect(Bool(false), "Expected noConnection error")
            return
        }
    }

    @Test
    func request_returnsRequestTimeout_onTimedOutError() async {
        // Arrange
        MockURLProtocol.stub(error: URLError(.timedOut))
        let sut = makeSUT()
        let apiRequest = MockAPIRequest(endpoint: "/items")

        // Act
        let result: Result<TestModel, APIClientError> = await sut.request(apiRequest: apiRequest)

        // Assert
        guard case .failure(.requestTimeout) = result else {
            #expect(Bool(false), "Expected requestTimeout error")
            return
        }
    }

    @Test
    func request_returnsRequestTimeout_onCancelledError() async {
        // Arrange
        MockURLProtocol.stub(error: URLError(.cancelled))
        let sut = makeSUT()
        let apiRequest = MockAPIRequest(endpoint: "/items")

        // Act
        let result: Result<TestModel, APIClientError> = await sut.request(apiRequest: apiRequest)

        // Assert
        guard case .failure(.requestTimeout) = result else {
            #expect(Bool(false), "Expected requestTimeout error")
            return
        }
    }

    @Test
    func request_returnsUnknownError_onOtherURLError() async {
        // Arrange
        MockURLProtocol.stub(error: URLError(.badURL))
        let sut = makeSUT()
        let apiRequest = MockAPIRequest(endpoint: "/items")

        // Act
        let result: Result<TestModel, APIClientError> = await sut.request(apiRequest: apiRequest)

        // Assert
        guard case .failure(.unknownError) = result else {
            #expect(Bool(false), "Expected unknownError")
            return
        }
    }

    @Test
    func request_returnsUnknownError_onNonURLError() async {
        // Arrange
        MockURLProtocol.stub(error: NSError(domain: "TestDomain", code: 123))
        let sut = makeSUT()
        let apiRequest = MockAPIRequest(endpoint: "/items")

        // Act
        let result: Result<TestModel, APIClientError> = await sut.request(apiRequest: apiRequest)

        // Assert
        guard case .failure(.unknownError) = result else {
            #expect(Bool(false), "Expected unknownError")
            return
        }
    }

    @Test
    func request_constructsURLWithQueryParameters() async {
        // Arrange
        MockURLProtocol.stub(data: encoded(TestModel(id: 1, name: "Test")), statusCode: 200)
        let sut = makeSUT()
        let apiRequest = MockAPIRequest(
            endpoint: "/items",
            queryParams: ["search": "test", "limit": "10"]
        )

        // Act
        let _: Result<TestModel, APIClientError> = await sut.request(apiRequest: apiRequest)

        // Assert
        let capturedURL = MockURLProtocol.lastRequest?.url
        #expect(capturedURL?.query?.contains("search=test") ?? false)
        #expect(capturedURL?.query?.contains("limit=10") ?? false)
    }

    @Test
    func request_setsCorrectHTTPMethod() async {
        // Arrange
        MockURLProtocol.stub(data: encoded(TestModel(id: 1, name: "Test")), statusCode: 200)
        let sut = makeSUT()
        let apiRequest = MockAPIRequest(endpoint: "/items", method: .POST)

        // Act
        let _: Result<TestModel, APIClientError> = await sut.request(apiRequest: apiRequest)

        // Assert
        #expect(MockURLProtocol.lastRequest?.httpMethod == HTTPMethod.POST.rawValue)
    }

    @Test
    func request_setsContentTypeHeader() async {
        // Arrange
        MockURLProtocol.stub(data: encoded(TestModel(id: 1, name: "Test")), statusCode: 200)
        let sut = makeSUT()
        let apiRequest = MockAPIRequest(endpoint: "/items")

        // Act
        let _: Result<TestModel, APIClientError> = await sut.request(apiRequest: apiRequest)

        // Assert
        #expect(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test
    func request_includesCustomHeaders() async {
        // Arrange
        MockURLProtocol.stub(data: encoded(TestModel(id: 1, name: "Test")), statusCode: 200)
        let sut = makeSUT()
        let apiRequest = MockAPIRequest(
            endpoint: "/items",
            headers: ["Authorization": "Bearer token123", "X-Custom": "value"]
        )

        // Act
        let _: Result<TestModel, APIClientError> = await sut.request(apiRequest: apiRequest)

        // Assert
        #expect(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer token123")
        #expect(MockURLProtocol.lastRequest?.value(forHTTPHeaderField: "X-Custom") == "value")
    }

    @Test
    func request_includesRequestBody() async {
        // Arrange
        MockURLProtocol.stub(data: encoded(TestModel(id: 1, name: "Test")), statusCode: 201)
        let sut = makeSUT()
        let requestBody: [String: Any] = ["name": "Test Item", "value": 42]
        let apiRequest = MockAPIRequest(endpoint: "/items", method: .POST, body: requestBody)

        // Act
        let _: Result<TestModel, APIClientError> = await sut.request(apiRequest: apiRequest)

        // Assert
        let bodyData = MockURLProtocol.lastRequest?.httpBody
        #expect(bodyData != nil)
        if let bodyData,
           let bodyDict = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any] {
            #expect(bodyDict["name"] as? String == "Test Item")
            #expect(bodyDict["value"] as? Int == 42)
        }
    }

    // MARK: - Helpers

    private func encoded<T: Encodable>(_ value: T) -> Data {
        (try? JSONEncoder().encode(value)) ?? Data()
    }

    private func makeSUT(baseURL: URL? = nil) -> PublicAPIClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        return PublicAPIClient(baseURL: baseURL ?? self.baseURL, session: session)
    }
}

// MARK: - Mocks

/// Intercepts all outgoing URL requests within a URLSession configured with this protocol,
/// returning pre-configured stub responses without making real network calls.
/// Uses Apple's official URLProtocol interception mechanism (Foundation framework).
private final class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) private(set) static var lastRequest: URLRequest?
    nonisolated(unsafe) private static var stubbedData: Data?
    nonisolated(unsafe) private static var stubbedResponse: HTTPURLResponse?
    nonisolated(unsafe) private static var stubbedError: Error?

    static func stub(data: Data = Data(), statusCode: Int) {
        stubbedData = data
        stubbedResponse = HTTPURLResponse(
            url: URL(string: "https://stub")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        stubbedError = nil
        lastRequest = nil
    }

    static func stub(error: Error) {
        stubbedError = error
        stubbedData = nil
        stubbedResponse = nil
        lastRequest = nil
    }

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        var capturedRequest = request
        if let stream = request.httpBodyStream {
            stream.open()
            var bodyData = Data()
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 4096)
            while stream.hasBytesAvailable {
                let read = stream.read(buffer, maxLength: 4096)
                if read > 0 { bodyData.append(buffer, count: read) }
            }
            buffer.deallocate()
            stream.close()
            capturedRequest.httpBody = bodyData
        }
        MockURLProtocol.lastRequest = capturedRequest

        if let error = MockURLProtocol.stubbedError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        if let response = MockURLProtocol.stubbedResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = MockURLProtocol.stubbedData {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

private struct MockAPIRequest: APIRequest {
    let method: HTTPMethod
    let endpoint: String
    let headers: [String: String]?
    let queryParams: [String: String]?
    let body: [String: Any]?

    @MainActor
    init(
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

private struct TestModel: Codable, Equatable {
    let id: Int
    let name: String
}
