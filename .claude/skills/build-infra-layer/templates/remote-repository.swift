// MARK: - Remote Repository Skeleton
// File: ClickNBack/Infra/Repositories/<Feature>/Remote<Feature>Repository.swift
//
// Holds only the init — methods live in +<operation>.swift extensions.
// Use `private(set) var` (not `private let`) so extensions in other files can read the property.

import Foundation

public final class Remote<Feature>Repository: <Feature>Repository {
    private(set) var apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
}

// MARK: - Operation Extension
// File: ClickNBack/Infra/Repositories/<Feature>/Remote<Feature>Repository+<operation>.swift
//
// One file per repository method. Private mapper extensions go at the bottom of the same file.

import Foundation

extension Remote<Feature>Repository {
    public func fetch<Models>(offset: Int, limit: Int) async -> Fetch<Model>sResult {
        let result: Result<Paginated<Model>sResponse, APIClientError> =
            await apiClient.request(apiRequest: <Feature>APIRequest.list<Models>(
                offset: offset,
                limit: limit
            ))

        switch result {
        case .success(let response):
            return .success(response.to<Feature>sPage())
        case .failure(let error):
            switch error {
            case .apiError(401, _):
                return .failure(.unauthorized)
            case .apiError:
                return .failure(.unexpectedError)
            case .serverError:
                return .failure(.serverError)
            case .requestTimeout:
                return .failure(.requestTimeout)
            case .noConnection:
                return .failure(.noConnectivity)
            default:
                return .failure(.unexpectedError)
            }
        }
    }
}

// MARK: - Mappers
//
// Always private extensions in this file — never public methods on the DTO.
// This keeps DTOs pure and the mapping logic close to where it's used.

private extension Paginated<Model>sResponse {
    func to<Feature>sPage() -> <Feature>sPage {
        <Feature>sPage(
            <models>: data.map { $0.to<Model>() },
            pagination: Pagination(
                offset: pagination.offset,
                limit: pagination.limit,
                total: pagination.total
            )
        )
    }
}

private extension <Model>Response {
    func to<Model>() -> <Model> {
        let formatter = ISO8601DateFormatter()
        return <Model>(
            id: id,
            merchantName: merchantName,
            amount: Decimal(string: amount) ?? .zero,            // String → Decimal
            status: <Model>Status(rawValue: status) ?? .pending,  // String → typed enum (safe fallback)
            cashbackAmount: Decimal(string: cashbackAmount) ?? .zero,
            cashbackStatus: cashbackStatus,
            createdAt: formatter.date(from: createdAt) ?? Date()  // String → Date
        )
    }
}
