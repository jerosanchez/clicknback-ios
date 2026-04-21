//

import Foundation

final class CheckAuthStatusStartupTask: StartupTask {
    private let useCase: CheckAuthStatusUseCase
    private let appState: AppState
    private let minimumSplashDuration: Duration

    init(
        useCase: CheckAuthStatusUseCase,
        appState: AppState,
        minimumSplashDuration: Duration = .seconds(1.5)
    ) {
        self.useCase = useCase
        self.appState = appState
        self.minimumSplashDuration = minimumSplashDuration
    }

    func run() async {
        let isAuthenticated = useCase.execute()
        try? await Task.sleep(for: minimumSplashDuration)
        appState.authStatus = isAuthenticated ? .authenticated : .unauthenticated
    }
}
