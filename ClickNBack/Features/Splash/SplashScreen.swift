//

import SwiftUI

struct SplashScreen: View {

    @State var viewModel: SplashViewModel

    var body: some View {
        ZStack {
            AppColors.Brand.splashBackground
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.extraLarge) {
                splashIcon()
                appNameText()
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    // MARK: - Helpers

    private func splashIcon() -> some View {
        ZStack {
            Image(systemName: AppIcons.splashPrimary)
                .font(.system(size: AppDimensions.Splash.iconSize, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)

            Image(systemName: AppIcons.splashSecondary)
                .font(.system(size: AppDimensions.Splash.overlayIconSize, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    private func appNameText() -> some View {
        Text(L10nKey.Splash.Screen.appName)
            .font(AppTypography.displayLarge)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .tracking(AppDimensions.Splash.appNameLetterSpacing)
    }
}

#Preview {
    PreviewContainer.splashScreen()
}
