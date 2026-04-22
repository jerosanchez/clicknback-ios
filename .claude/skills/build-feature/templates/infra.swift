// MARK: - API Request Enum
// File: ClickNBack/Infra/Repositories/<Feature>/<Feature>APIRequest.swift

enum <Feature>APIRequest: APIRequest {
    case <action>(...)

    var endpoint: String {
        switch self {
        case .<action>: return "v1/<feature>/<action>"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .<action>: return .get  // or .post, .put, .delete
        }
    }

    var body: Encodable? {
        switch self {
        case .<action>(let params): return params
        }
    }
}

// MARK: - Remote Repository Skeleton
// File: ClickNBack/Infra/Repositories/<Feature>/Remote<Feature>Repository.swift

public final class Remote<Feature>Repository: <Feature>Repository {
    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
}

// MARK: - Method Extension (one file per method)
// File: ClickNBack/Infra/Repositories/<Feature>/Remote<Feature>Repository+<method>.swift

extension Remote<Feature>Repository {
    public func <action>(...) async -> Result<<Model>, <Feature>Error> {
        let result: Result<<Response>, APIClientError> = await apiClient.request(
            apiRequest: <Feature>APIRequest.<action>(...)
        )
        return result
            .mapError { <Feature>Error(from: $0) }
            .map { $0.to<Model>() }
    }
}

// MARK: - Mapper Extensions (private, in the same file)
// Mapper methods are always private extensions on DTOs, never public methods on the response DTO itself.
// This keeps the DTOs pure and the mapping logic close to where it's used.

private extension <Response> {
    func to<Model>() -> <Model> {
        <Model>(/* map fields from self */)
    }
}
