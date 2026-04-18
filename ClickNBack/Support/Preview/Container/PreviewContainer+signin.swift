//

import SwiftUI

extension PreviewContainer {
    static func signInScreen(loginHandler: LoginHandler? = nil) -> some View {
        let authRepository = MockAuthRepository()
        authRepository.loginHandler = loginHandler
        
        return SignInScreen(
            viewModel: SignInViewModel(
                loginUseCase: LoginUseCase(
                    authRepository: authRepository,
                    tokenStorage: MockKeyValueStorage()
                ),
                analyticsTracker: MockAnalyticsTracker()
            )
        )
    }
}
