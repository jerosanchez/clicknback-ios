//

import SwiftUI

struct SignInFormView: View {
    let viewModel: SignInViewModel

    var body: some View {
        VStack {
            AppIcons.inlineBigIcon(AppIcons.authHeadingIcon)
            formFields()
            signInButton()
        }
        .padding(AppSpacing.medium)
    }

    private func formFields() -> some View {
        VStack(spacing: AppSpacing.medium) {
            emailField()
            passwordField()
        }
        .padding(.vertical, AppSpacing.medium)
    }

    private func emailField() -> some View {
        TextField(L10nKey.SignIn.Form.emailField, text: Binding(
            get: { viewModel.email },
            set: { viewModel.email = $0 }
        ))
        .keyboardType(.emailAddress)
        .autocapitalization(.none)
        .padding()
        .padding(.leading, AppSpacing.large)
        .background(AppColors.Background.secondary)
        .cornerRadius(AppDimensions.CornerRadius.medium)
        .overlay(
            AppIcons.formFieldIcon(AppIcons.emailField)
        )
    }

    private func passwordField() -> some View {
        SecureField(L10nKey.SignIn.Form.passwordField, text: Binding(
            get: { viewModel.password },
            set: { viewModel.password = $0 }
        ))
        .padding()
        .padding(.leading, AppSpacing.large)
        .background(AppColors.Background.secondary)
        .cornerRadius(AppDimensions.CornerRadius.medium)
        .overlay(
            AppIcons.formFieldIcon(AppIcons.passwordField)
        )
    }

    private func signInButton() -> some View {
        Button(
            action: {
                Task {
                    await viewModel.signInTapped()
                }
            },
            label: {
                HStack {
                    Image(systemName: AppIcons.signinButton)
                    Text(L10nKey.SignIn.Form.button)
                        .font(AppTypography.Label.large)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(AppSpacing.medium)
                .background(AppColors.Semantic.primary)
                .foregroundColor(.white)
                .cornerRadius(AppDimensions.CornerRadius.medium)
            }
        )
        .padding(.top, AppSpacing.compact)
    }

    private var isFormValid: Bool {
        !viewModel.email.trimmingCharacters(in: .whitespaces).isEmpty &&
            !viewModel.password.isEmpty
    }
}

#Preview {
    PreviewContainer.signInFormView()
}
