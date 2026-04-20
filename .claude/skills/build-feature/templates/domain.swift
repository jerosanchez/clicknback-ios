// MARK: - Repository Protocol
// File: ClickNBack/Data/<Feature>/<Feature>Repository.swift

public protocol <Feature>Repository {
    func <action>(...) async -> Result<<Model>, <Feature>Error>
}

// MARK: - Domain Model
// File: ClickNBack/Data/<Feature>/<Model>.swift

public struct <Model>: Equatable, Sendable {
    public let id: String
    // add properties

    public init(id: String, ...) {
        self.id = id
        // ...
    }
}

// MARK: - Typed Error
// File: ClickNBack/Data/<Feature>/<Feature>Error.swift

public enum <Feature>Error: Error, Equatable {
    case notFound
    case serverError
    case noConnectivity
    case unexpectedError(Error?)

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.notFound, .notFound), (.serverError, .serverError), (.noConnectivity, .noConnectivity):
            return true
        case (.unexpectedError, .unexpectedError):
            return true
        default:
            return false
        }
    }
}

// MARK: - Use Case
// File: ClickNBack/Data/<Feature>/<Action>UseCase.swift

public final class <Action>UseCase {
    private let repository: <Feature>Repository

    public init(repository: <Feature>Repository) {
        self.repository = repository
    }

    public func execute(...) async -> Result<..., <Feature>Error> {
        await repository.<action>(...)
    }
}
