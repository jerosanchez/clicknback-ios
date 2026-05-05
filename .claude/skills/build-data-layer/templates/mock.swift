// MARK: - Mock Repository
// File: ClickNBack/Support/Mocks/Mock<Feature>Repository.swift

public typealias Fetch<Model>Handler = (Int, Int) async -> Fetch<Model>Result

public final class Mock<Feature>Repository: <Feature>Repository {
    public private(set) var fetch<Models>CallCount = 0
    public var fetch<Models>Handler: Fetch<Model>Handler?

    public init() {}

    public func fetch<Models>(offset: Int, limit: Int) async -> Fetch<Model>Result {
        fetch<Models>CallCount += 1
        return await fetch<Models>Handler?(offset, limit) ?? .success(.mock)
    }
}

// MARK: - Single Mock Item
// File: ClickNBack/Support/Preview/Data/<Model>+mock.swift

import Foundation

extension <Model> {
    public static var mock: <Model> {
        <Model>(
            id: "550e8400-e29b-41d4-a716-446655440000",  // fixed UUID
            // ...
        )
    }
}

extension Array where Element == <Model> {
    public static var mock: [<Model>] {
        [
            <Model>(id: "550e8400-e29b-41d4-a716-446655440000", ...),
            <Model>(id: "550e8400-e29b-41d4-a716-446655440001", ...),
            <Model>(id: "550e8400-e29b-41d4-a716-446655440002", ...)
        ]
    }
}

// MARK: - Page Mock (paginated only)
// File: ClickNBack/Support/Preview/Data/<Feature>sPage+mock.swift

extension <Feature>sPage {
    public static var mock: <Feature>sPage {
        <Feature>sPage(
            <models>: .mock,
            pagination: Pagination(offset: 0, limit: 10, total: 3)
        )
    }
}
