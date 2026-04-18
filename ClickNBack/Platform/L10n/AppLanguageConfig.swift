//

import Foundation

@Observable
final class AppLanguageConfig {
    var storage: KeyValueStorage

    init(
        storage: KeyValueStorage
    ) {
        self.storage = storage
    }

    var language: AppLanguage {
        guard let languageRawValue = try? storage.get(String.self, forKey: L10nStorageKey.appLanguage.rawValue),
              let language = AppLanguage(rawValue: languageRawValue)
        else {
            return .english // Defaults to English
        }
        return language
    }
}
