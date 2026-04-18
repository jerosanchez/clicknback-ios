//

import Foundation

public final class PublicAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession

    public init(
        baseURL: URL,
        session: URLSession,
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    public func request<T: Decodable>(apiRequest: APIRequest) async -> Result<T, APIClientError> {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(apiRequest.endpoint),
            resolvingAgainstBaseURL: false
        ) else {
            return .failure(.invalidURL)
        }

        if let queryParams = apiRequest.queryParams {
            components.queryItems = queryParams.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }

        guard let url = components.url else {
            return .failure(.invalidURL)
        }

        let request = buildURLRequest(url: url, apiRequest: apiRequest)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            return handleURLError(urlError)
        } catch {
            return .failure(.unknownError(error))
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            let userInfo = [NSLocalizedDescriptionKey: "Invalid response"]
            let error = NSError(domain: "Networking", code: 666, userInfo: userInfo)
            return .failure(.unknownError(error))
        }

        let statusCode = httpResponse.statusCode

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
