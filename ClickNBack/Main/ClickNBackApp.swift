//

import SwiftUI

@main
struct ClickNBackApp: App {
    @State var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootContainer(
                startupTasks: CompositionRoot.startupTasks(appState: appState)
            )
            .environment(appState)
            .environment(\.locale, appState.language.locale)
        }
    }
}
