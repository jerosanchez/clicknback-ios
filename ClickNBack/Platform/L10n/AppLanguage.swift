//

import Foundation

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case spanish = "es"

    var locale: Locale {
        Locale(identifier: rawValue)
    }
}
