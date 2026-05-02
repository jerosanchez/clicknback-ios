//

import Foundation

public final class PublicAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let logger: Logger

    public init(
        baseURL: URL,
        session: URLSession,
        logger: Logger
    ) {
        self.baseURL = baseURL
        self.session = session
        self.logger = logger
    }

    public func request<T: Decodable>(apiRequest: APIRequest) async -> Result<T, APIClientError> {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(apiRequest.endpoint),
            resolvingAgainstBaseURL: false
        ) else {
            logger.error("[\(apiRequest.method.rawValue)] \(apiRequest.endpoint) — invalid URL")
            return .failure(.invalidURL)
        }

        if let queryParams = apiRequest.queryParams {
            components.queryItems = queryParams.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        guard let url = components.url else {
            logger.error("[\(apiRequest.method.rawValue)] \(apiRequest.endpoint) — could not build URL from components")
            return .failure(.invalidURL)
        }

        let request = buildURLRequest(url: url, apiRequest: apiRequest)

        logger.debug("→ [\(apiRequest.method.rawValue)] \(url.absoluteString)")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            logger.error("← [\(apiRequest.method.rawValue)] \(url.absoluteString) — URLError: \(urlError.localizedDescription)")
            return handleURLError(urlError)
        } catch {
            logger.error("← [\(apiRequest.method.rawValue)] \(url.absoluteString) — unknown error: \(error)")
            return .failure(.unknownError(error))
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("← [\(apiRequest.method.rawValue)] \(url.absoluteString) — non-HTTP response")
            let userInfo = [NSLocalizedDescriptionKey: "Invalid response"]
            let error = NSError(domain: "Networking", code: 666, userInfo: userInfo)
            return .failure(.unknownError(error))
        }

        let statusCode = httpResponse.statusCode

        logger.debug("← [\(apiRequest.method.rawValue)] \(url.absoluteString) — HTTP \(statusCode)")

        return handleResponse(data, statusCode: statusCode)
    }

    private func buildURLRequest(url: URL, apiRequest: APIRequest) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = apiRequest.method.rawValue

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        apiRequest.headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        if let body = apiRequest.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        return request
    }

    private func handleURLError<T: Decodable>(_ error: URLError) -> Result<T, APIClientError> {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .failure(.noConnection)
        case .timedOut, .cancelled:
            return .failure(.requestTimeout)
        default:
            return .failure(.unknownError(error))
        }
    }

    private func handleResponse<T: Decodable>(_ data: Data, statusCode: Int) -> Result<T, APIClientError> {
        switch statusCode {
        case 200 ... 299:
            guard let dto = try? JSONDecoder().decode(T.self, from: data) else {
                logger.error("Decoding failed for HTTP \(statusCode) response (\(data.count) bytes)")
                return .failure(.decodingError)
            }
            return .success(dto)
        case 400 ... 499:
            return .failure(.apiError(statusCode, data))
        case 500 ... 599:
            return .failure(.serverError(statusCode))
        default:
            return .failure(.unknownError(nil))
        }
    }
}
