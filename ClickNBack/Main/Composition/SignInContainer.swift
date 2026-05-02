//

import SwiftUI

struct SignInContainer: View {
    @Environment(AppState.self) private var appState

    @State private var viewModel = SignInViewModel(
        loginUseCase: LoginUseCase(
            authRepository: RemoteAuthRepository(
                apiClient: CompositionRoot.apiClient
            ),
            tokenStorage: CompositionRoot.secureStorage
        ),
        analyticsTracker: CompositionRoot.analyticsTracker
    )

    var body: some View {
        SignInScreen(viewModel: viewModel)
            .onAppear {
                viewModel.onLoginSuccess = {
                    appState.authStatus = .authenticated
                }
            }
    }
}
