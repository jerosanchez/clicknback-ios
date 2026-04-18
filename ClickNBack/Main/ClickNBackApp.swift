//

import SwiftUI

@main
struct ClickNBackApp: App {
    @State var appState = AppState()

    var body: some Scene {
        WindowGroup {
            SignInContainer()
            .environment(appState)
            .environment(\.locale, appState.language.locale)
        }
    }
}
