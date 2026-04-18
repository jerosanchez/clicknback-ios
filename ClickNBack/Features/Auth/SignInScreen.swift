//

import SwiftUI

struct SignInScreen: View {

    @State var viewModel: SignInViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.large) {
                SignInFormView(viewModel: viewModel)
                SignInResultView(state: viewModel.state)
                Spacer()
            }
            .padding(AppSpacing.medium)
            .navigationTitle(L10nKey.SignIn.Screen.title)
            .disabled(viewModel.isLoading)
        }
        .overlay(alignment: .center) {
            if viewModel.isLoading {
                loadingOverlay()
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    private func loadingOverlay() -> some View {
        ZStack {
            AppColors.Overlay.medium
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.large) {
                ProgressView()
                Text(L10nKey.SignIn.Screen.waitingMessage)
                    .font(AppTypography.Body.medium)
                    .foregroundColor(AppColors.Text.primary)
            }
            .padding(AppDimensions.CornerRadius.large)
            .background(AppColors.Background.primary)
            .cornerRadius(AppDimensions.CornerRadius.medium)
        }
    }
}

#Preview {
    PreviewContainer.signInScreen(loginHandler: { _ in .success(.mock) })
}
