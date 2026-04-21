//

import SwiftUI

extension PreviewContainer {
    static func rootContainer(
        authStatus: AuthStatus = .unauthenticated,
        appLanguage: AppLanguage = .english
    ) -> some View {
        let appState = AppState()
        appState.authStatus = authStatus
        return RootContainer(startupTasks: [])
            .environment(appState)
            .environment(\.locale, appLanguage.locale)
    }
}
