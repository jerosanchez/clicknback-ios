//

import Foundation

/// Intercepts all outgoing URL requests within a URLSession configured with this protocol,
/// returning pre-configured stub responses without making real network calls.
/// Uses Apple's official URLProtocol interception mechanism (Foundation framework).
final class MockURLProtocol: URLProtocol {
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
