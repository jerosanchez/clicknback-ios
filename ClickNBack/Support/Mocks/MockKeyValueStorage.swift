//

import Foundation

public final class MockKeyValueStorage: KeyValueStorage {
    private var storage: [String: Data] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Configurable hooks (optional overrides)

    public var setHandler: ((String, Data) throws -> Void)?
    public var getHandler: ((String) throws -> Data?)?
    public var removeHandler: ((String) throws -> Void)?

    public init() {}

    // MARK: - API

    public func set(_ value: some Codable, forKey key: String) throws {
        let data = try encoder.encode(value)

        if let handler = setHandler {
            try handler(key, data)
            return
        }

        storage[key] = data
    }

    public func get<T: Codable>(_: T.Type, forKey key: String) throws -> T? {
        if let handler = getHandler {
            guard let data = try handler(key) else { return nil }
            return try decoder.decode(T.self, from: data)
        }

        guard let data = storage[key] else { return nil }

        return try decoder.decode(T.self, from: data)
    }

    public func remove(forKey key: String) throws {
        if let handler = removeHandler {
            try handler(key)
            return
        }

        storage.removeValue(forKey: key)
    }

    // MARK: - Testing Helpers

    public func value(forKey key: String) -> String? {
        try? get(String.self, forKey: key)
    }
}
