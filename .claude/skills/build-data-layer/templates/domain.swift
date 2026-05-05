// MARK: - Domain Model
// File: ClickNBack/Data/<Feature>/<Model>.swift

import Foundation

public struct <Model>: Equatable {
    public let id: String
    // Monetary amounts → Decimal (never Double or String)
    // Optional fields → explicit ?
    // Dates → Date (ISO 8601 parsing done by the DTO mapper in Infra)

    public init(id: String, ...) {
        self.id = id
        // ...
    }
}

// MARK: - Status Enum (only when the model has a status field)
// File: ClickNBack/Data/<Feature>/<Model>Status.swift

public enum <Model>Status: String, Equatable {
    case pending
    case confirmed
    // All API-returned values — never omit a case (domain and DTO must handle all values)
}

// MARK: - Pagination (only when the endpoint is paginated)
// Use the shared Pagination struct from ClickNBack/Data/Shared/Pagination.swift.
// Never create a feature-specific pagination type.

// File: ClickNBack/Data/<Feature>/<Feature>sPage.swift

public struct <Feature>sPage: Equatable {
    public let <models>: [<Model>]
    public let pagination: Pagination

    public init(<models>: [<Model>], pagination: Pagination) {
        self.<models> = <models>
        self.pagination = pagination
    }
}

// MARK: - Error Enum
// File: ClickNBack/Data/<Feature>/Fetch<Model>Error.swift

public enum Fetch<Model>Error: Error, Equatable {
    case unauthorized   // 401
    case serverError    // 5xx
    case requestTimeout
    case noConnectivity
    case unexpectedError
}

// MARK: - Repository Protocol
// File: ClickNBack/Data/<Feature>/<Feature>Repository.swift
// Define the Result typealias at the top of the file.

public typealias Fetch<Model>Result = Result<<Feature>sPage, Fetch<Model>Error>

public protocol <Feature>Repository {
    func fetch<Models>(offset: Int, limit: Int) async -> Fetch<Model>Result
}

// MARK: - Use Case
// File: ClickNBack/Data/<Feature>/Fetch<Model>UseCase.swift
// One public execute method. Never add secondary getters — extract as a separate use case.

public final class Fetch<Model>UseCase {
    private let <feature>Repository: <Feature>Repository

    public init(<feature>Repository: <Feature>Repository) {
        self.<feature>Repository = <feature>Repository
    }

    public func execute(offset: Int, limit: Int) async -> Fetch<Model>Result {
        await <feature>Repository.fetch<Models>(offset: offset, limit: limit)
    }
}
