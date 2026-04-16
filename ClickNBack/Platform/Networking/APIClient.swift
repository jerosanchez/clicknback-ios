//

public protocol APIClient {
    func request<T: Decodable>(apiRequest: APIRequest) async -> Result<T, APIClientError>
}
