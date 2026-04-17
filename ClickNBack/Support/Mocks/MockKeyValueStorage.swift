//

import Foundation

final class MockKeyValueStorage: KeyValueStorage {
    private var storage: [String: Data] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Configurable hooks (optional overrides)

    var setHandler: ((String, Data) throws -> Void)?
    var getHandler: ((String) throws -> Data?)?
    var removeHandler: ((String) throws -> Void)?

    // MARK: - API

    func set(_ value: some Codable, forKey key: String) throws {
        let data = try encoder.encode(value)

        if let handler = setHandler {
            try handler(key, data)
            return
        }

        storage[key] = data
    }

    func get<T: Codable>(_: T.Type, forKey key: String) throws -> T? {
        if let handler = getHandler {
            guard let data = try handler(key) else { return nil }
            return try decoder.decode(T.self, from: data)
        }

        guard let data = storage[key] else { return nil }

        return try decoder.decode(T.self, from: data)
    }

    func remove(forKey key: String) throws {
        if let handler = removeHandler {
            try handler(key)
            return
        }

        storage.removeValue(forKey: key)
    }
}
