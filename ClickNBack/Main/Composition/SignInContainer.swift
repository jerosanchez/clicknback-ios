//

import SwiftUI

struct SignInContainer: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        SignInScreen(
            viewModel: SignInViewModel(
                loginUseCase: LoginUseCase(
                    authRepository: RemoteAuthRepository(
                        apiClient: CompositionRoot.apiClient
                    ),
                    tokenStorage: CompositionRoot.secureStorage
                ),
                analyticsTracker: CompositionRoot.analyticsTracker
            )
        )
    }
}
