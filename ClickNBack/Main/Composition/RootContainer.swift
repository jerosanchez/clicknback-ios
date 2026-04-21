//

import SwiftUI

struct RootContainer: View {
    @Environment(AppState.self) private var appState

    private let startupTasks: [any StartupTask]

    init(
        startupTasks: [any StartupTask]
    ) {
        self.startupTasks = startupTasks
    }

    var body: some View {
        Group {
            switch appState.authStatus {
            case .checking:
                SplashContainer()
            case .authenticated:
                HomeScreen()
            case .unauthenticated:
                SignInContainer()
            }
        }
        .task {
            for task in startupTasks {
                await task.run()
            }
        }
    }
}

#Preview("Splash (checking)") {
    PreviewContainer.rootContainer(authStatus: .checking)
}

#Preview("Sign In (unauthenticated)") {
    PreviewContainer.rootContainer(authStatus: .unauthenticated)
}

#Preview("Home (authenticated)") {
    PreviewContainer.rootContainer(authStatus: .authenticated)
}
