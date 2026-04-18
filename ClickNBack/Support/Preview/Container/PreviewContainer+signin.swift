//

import SwiftUI

extension PreviewContainer {
    static func signInScreen(
        loginHandler: LoginHandler? = nil,
        appLanguage: AppLanguage = .english
    ) -> some View {
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
        .environment(\.locale, appLanguage.locale)
    }
    
    static func signInFormView(
        appLanguage: AppLanguage = .english
    ) -> some View {
        return SignInFormView(
            viewModel: SignInViewModel(
                loginUseCase: LoginUseCase(
                    authRepository: MockAuthRepository(),
                    tokenStorage: MockKeyValueStorage()
                ),
                analyticsTracker: MockAnalyticsTracker()
            )
        )
        .environment(\.locale, appLanguage.locale)
    }
            
        
    
    static func signInResultView(
        state: SignInViewModel.State = .success,
        appLanguage: AppLanguage = .english
    ) -> some View {
        SignInResultView(state: state)
        .environment(\.locale, appLanguage.locale)
    }
}
