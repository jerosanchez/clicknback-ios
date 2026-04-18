//

import SwiftUI

struct SignInResultView: View {
    var state: SignInViewModel.State

    var body: some View {
        Group {
            switch state {
            case .idle, .loading:
                EmptyView()
            case .success:
                resultView(
                    message: L10nKey.SignIn.Result.successMessage,
                    withIcon: AppIcons.Status.success,
                    color: AppColors.Status.success
                )
            case .error(.badCredentials):
                resultView(
                    message: L10nKey.SignIn.Result.badCredentialsMessage,
                    withIcon: AppIcons.Status.error,
                    color: AppColors.Status.error
                )
            case .error(.serverError):
                resultView(
                    message: L10nKey.SignIn.Result.errorMessage,
                    withIcon: AppIcons.Status.error,
                    color: AppColors.Status.error
                )
            case .error(.timeout):
                resultView(
                    message: L10nKey.SignIn.Result.timeoutMessage,
                    withIcon: AppIcons.Status.warning,
                    color: AppColors.Status.warning
                )
            case .error(.noConnectivity):
                resultView(
                    message: L10nKey.SignIn.Result.noConnectivityMessage,
                    withIcon: AppIcons.Status.warning,
                    color: AppColors.Status.warning
                )
            }
        }
    }

    private func resultView(message: LocalizedStringResource, withIcon icon: String, color: Color) -> some View {
        VStack(spacing: AppSpacing.large) {
            AppIcons.inlineBigIcon(icon, color: color)

            Text(message)
                .font(AppTypography.Headline.medium)
                .foregroundColor(AppColors.Text.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.Background.primary)
    }
}

#Preview("Success") {
    PreviewContainer.signInResultView(state: .success)
}

#Preview("Success (ES)") {
    PreviewContainer.signInResultView(state: .success, appLanguage: .spanish)
}

#Preview("Bad Credentials") {
    PreviewContainer.signInResultView(state: .error(.badCredentials))
}

#Preview("Server Error") {
    PreviewContainer.signInResultView(state: .error(.serverError))
}

#Preview("Timeout") {
    PreviewContainer.signInResultView(state: .error(.timeout))
}

#Preview("No Connectivity") {
    PreviewContainer.signInResultView(state: .error(.noConnectivity))
}
