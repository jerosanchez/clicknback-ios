public typealias FetchActiveHandler = (Int, Int) async -> FetchActiveOffersResult

public final class MockOffersRepository: OffersRepository {
    public private(set) var fetchActiveCallCount = 0
    public var fetchActiveHandler: FetchActiveHandler?

    public init() {}

    public func fetchActive(offset: Int, limit: Int) async -> FetchActiveOffersResult {
        fetchActiveCallCount += 1
        return await fetchActiveHandler?(offset, limit) ?? .success(.mock)
    }
}
