//

import Foundation

public protocol KeyValueStorage {
    func set(_ value: some Codable, forKey key: String) throws
    func get<T: Codable>(_ type: T.Type, forKey key: String) throws -> T?
    func remove(forKey key: String) throws
}
