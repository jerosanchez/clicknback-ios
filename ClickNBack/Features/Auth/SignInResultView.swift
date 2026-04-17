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
                    message: "Sign in successful",
                    withIcon: AppIcons.Status.success,
                    color: AppColors.Status.success
                )
            case .badCredentials:
                resultView(
                    message: "Wrong user or password.\nPlease, try again.",
                    withIcon: AppIcons.Status.error,
                    color: AppColors.Status.error
                )
            case .serverError:
                resultView(
                    message: "There's a problem in our side.\nPlease try again later.",
                    withIcon: AppIcons.Status.error,
                    color: AppColors.Status.error
                )
            case .timeout:
                resultView(
                    message: "The operation is taking too long;\nMaybe be connectivity issues?\nPlease try again later.",
                    withIcon: AppIcons.Status.warning,
                    color: AppColors.Status.warning
                )
            case .noConnectivity:
                resultView(
                    message: "No internet connection.\nPlease check your connection and try again.",
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
    SignInResultView(state: .success)
}

#Preview("Bad Credentials") {
    SignInResultView(state: .badCredentials)
}

#Preview("Server Error") {
    SignInResultView(state: .serverError)
}

#Preview("Tiemout") {
    SignInResultView(state: .timeout)
}

#Preview("No Connectivity") {
    SignInResultView(state: .noConnectivity)
}
