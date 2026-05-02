//

import SwiftUI

public struct EmptyStateView: View {
    let imageSystemName: String
    let title: String
    let message: String

    public init(
        imageSystemName: String,
        title: String,
        message: String
    ) {
        self.imageSystemName = imageSystemName
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: AppSpacing.large) {
            Image(systemName: imageSystemName)
                .resizable()
                .scaledToFit()
                .frame(width: AppDimensions.Icon.extraLarge, height: AppDimensions.Icon.extraLarge)
                .foregroundStyle(AppColors.Text.disabled)

            VStack(spacing: AppSpacing.compact) {
                Text(title)
                    .font(AppTypography.Headline.medium)
                    .foregroundStyle(AppColors.Text.primary)

                Text(message)
                    .font(AppTypography.Body.medium)
                    .foregroundStyle(AppColors.Text.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppSpacing.extraLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        imageSystemName: "tag.slash",
        title: "No Items",
        message: "There are no items to display at the moment."
    )
}
