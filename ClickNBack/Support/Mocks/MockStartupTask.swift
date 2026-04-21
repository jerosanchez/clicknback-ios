//

public final class MockStartupTask: StartupTask {
    public var runCallCount = 0
    public var runHandler: (() async -> Void)?

    public init() {}

    public func run() async {
        runCallCount += 1
        await runHandler?()
    }
}
