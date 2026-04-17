//

import SwiftUI

struct SignInScreen: View {
    
    @State var viewModel: SignInViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.large) {
                SignInFormView(viewModel: viewModel)
                Spacer()
            }
            .padding(AppSpacing.medium)
            .navigationTitle("Sign In")
        }
    }

    private func loadingOverlay() -> some View {
        ZStack {
            AppColors.Overlay.medium
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.large) {
                ProgressView()
                Text("Signing in...")
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
    PreviewContainer.signInScreen()
}
