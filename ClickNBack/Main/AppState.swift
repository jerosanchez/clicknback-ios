//

import Foundation

@Observable final class AppState {
    var language: AppLanguage = .english
    var authStatus: AuthStatus = .checking
}
