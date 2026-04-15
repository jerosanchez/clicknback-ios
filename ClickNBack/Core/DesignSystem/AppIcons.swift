//

import SwiftUI

public enum AppIcons {
    // MARK: - Authentication Icons

    static var authHeadingIcon = "lock.shield.fill"
    static var signinButton = "person.badge.key"

    // MARK: - Form Icons

    static var emailField = "envelope"
    static var passwordField = "key"

    // MARK: - Status Icons

    enum Status {
        static var success = "checkmark.circle.fill"
        static var warning = "exclamationmark.circle.fill"
        static var error = "xmark.circle.fill"
    }
}

// MARK: - Icon builders

extension AppIcons {
    static func icon(
        _ name: String,
        size: CGFloat = AppDimensions.Icon.medium,
        color: Color = AppColors.Semantic.primary
    ) -> some View {
        Image(systemName: name)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundColor(color)
    }

    static func inlineBigIcon(
        _ name: String,
        color: Color = AppColors.Semantic.primary
    ) -> some View {
        Image(systemName: name)
            .resizable()
            .scaledToFit()
            .frame(
                width: AppDimensions.Icon.extraLarge,
                height: AppDimensions.Icon.extraLarge
            )
            .foregroundColor(color)
    }

    static func formFieldIcon(_ name: String) -> some View {
        HStack {
            Image(systemName: name)
                .foregroundColor(AppColors.Text.secondary)
            Spacer()
        }
        .padding(.leading, AppSpacing.compact)
    }
}
