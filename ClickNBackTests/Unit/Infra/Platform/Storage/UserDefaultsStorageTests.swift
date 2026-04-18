//

import ClickNBack
import Foundation
import Testing

@MainActor
@Suite("UserDefaultsStorage")
final class UserDefaultsStorageTests {

    @Test
    func set_persistsValue_forKey() throws {
        // Arrange
        let (sut, _) = makeSUT()
        let key = "test-key"
        let value = "stored-value"

        // Act
        try sut.set(value, forKey: key)

        // Assert
        let stored = try sut.get(String.self, forKey: key)
        #expect(stored == value)
    }

    @Test
    func get_returnsNil_whenKeyDoesNotExist() throws {
        // Arrange
        let (sut, _) = makeSUT()

        // Act
        let result = try sut.get(String.self, forKey: "nonexistent-key")

        // Assert
        #expect(result == nil)
    }

    @Test
    func get_returnsNil_afterRemovingValue() throws {
        // Arrange
        let (sut, _) = makeSUT()
        let key = "test-key"
        try sut.set("value", forKey: key)

        // Act
        try sut.remove(forKey: key)
        let result = try sut.get(String.self, forKey: key)

        // Assert
        #expect(result == nil)
    }

    @Test
    func remove_doesNotThrow_whenKeyDoesNotExist() throws {
        // Arrange
        let (sut, _) = makeSUT()

        // Act & Assert
        #expect(throws: Never.self) {
            try sut.remove(forKey: "nonexistent-key")
        }
    }

    @Test
    func set_overwritesPreviousValue_forSameKey() throws {
        // Arrange
        let (sut, _) = makeSUT()
        let key = "test-key"
        try sut.set("first-value", forKey: key)

        // Act
        try sut.set("second-value", forKey: key)

        // Assert
        let result = try sut.get(String.self, forKey: key)
        #expect(result == "second-value")
    }

    @Test
    func set_isolatesValuesByKey() throws {
        // Arrange
        let (sut, _) = makeSUT()
        let keyA = "key-a"
        let keyB = "key-b"

        // Act
        try sut.set("value-a", forKey: keyA)
        try sut.set("value-b", forKey: keyB)

        // Assert
        #expect(try sut.get(String.self, forKey: keyA) == "value-a")
        #expect(try sut.get(String.self, forKey: keyB) == "value-b")
    }

    @Test
    func set_persistsCodableStruct_forKey() throws {
        // Arrange
        let (sut, _) = makeSUT()
        let model = TestModel(id: 42, name: "clicknback")
        let key = "struct-key"

        // Act
        try sut.set(model, forKey: key)

        // Assert
        let stored = try sut.get(TestModel.self, forKey: key)
        #expect(stored == model)
    }

    @Test
    func remove_doesNotAffectOtherKeys() throws {
        // Arrange
        let (sut, _) = makeSUT()
        let keyToRemove = "key-to-remove"
        let keyToKeep = "key-to-keep"
        try sut.set("value-remove", forKey: keyToRemove)
        try sut.set("value-keep", forKey: keyToKeep)

        // Act
        try sut.remove(forKey: keyToRemove)

        // Assert
        #expect(try sut.get(String.self, forKey: keyToKeep) == "value-keep")
    }

    // MARK: - Helpers

    private var createdSuiteNames: [String] = []

    deinit {
        createdSuiteNames.forEach { UserDefaults().removePersistentDomain(forName: $0) }
    }

    private func makeSUT() -> (sut: UserDefaultsStorage, defaults: UserDefaults) {
        let suiteName = "com.clicknback.tests.\(UUID().uuidString)"
        createdSuiteNames.append(suiteName)
        let defaults = UserDefaults(suiteName: suiteName)!
        let sut = UserDefaultsStorage(defaults: defaults)
        return (sut, defaults)
    }

    private struct TestModel: Codable, Equatable {
        let id: Int
        let name: String
    }
}
