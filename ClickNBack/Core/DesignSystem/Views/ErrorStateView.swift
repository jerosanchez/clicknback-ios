//

import SwiftUI

public struct ErrorStateView<ErrorType: ErrorStateViewErrorType>: View {
    let error: ErrorType
    let message: String
    let retryButtonLabel: String
    let onRetry: () async -> Void

    public init(
        error: ErrorType,
        message: String,
        retryButtonLabel: String,
        onRetry: @escaping () async -> Void
    ) {
        self.error = error
        self.message = message
        self.retryButtonLabel = retryButtonLabel
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: AppSpacing.large) {
            Spacer()
            errorIcon
            Text(message)
                .font(AppTypography.Body.medium)
                .foregroundStyle(AppColors.Text.secondary)
                .multilineTextAlignment(.center)

            PillButton(
                label: retryButtonLabel,
                action: onRetry
            )
            Spacer()
        }
        .padding(AppSpacing.extraLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorIcon: some View {
        Image(systemName: error.errorStateIconName)
            .resizable()
            .scaledToFit()
            .frame(width: AppDimensions.Icon.extraLarge, height: AppDimensions.Icon.extraLarge)
            .foregroundStyle(AppColors.Text.disabled)
    }
}

/// Protocol that defines how an error type maps to an error state icon.
public protocol ErrorStateViewErrorType {
    var errorStateIconName: String { get }
}

// MARK: - Error State View Previews

struct MockErrorType: ErrorStateViewErrorType {
    let type: String

    var errorStateIconName: String {
        switch type {
        case "unauthorized":
            return AppIcons.ErrorState.unauthorized
        case "serverError":
            return AppIcons.ErrorState.serverError
        case "requestTimeout":
            return AppIcons.ErrorState.requestTimeout
        case "noConnectivity":
            return AppIcons.ErrorState.noConnectivity
        default:
            return AppIcons.ErrorState.unexpectedError
        }
    }
}

#Preview("Error State - Unauthorized", traits: .sizeThatFitsLayout) {
    ErrorStateView(
        error: MockErrorType(type: "unauthorized"),
        message: "Access denied. Please sign in again.",
        retryButtonLabel: "Sign In",
        onRetry: {}
    )
    .background(AppColors.Background.primary)
}

#Preview("Error State - Server Error", traits: .sizeThatFitsLayout) {
    ErrorStateView(
        error: MockErrorType(type: "serverError"),
        message: "Something went wrong on our end. Please try again.",
        retryButtonLabel: "Retry",
        onRetry: {}
    )
    .background(AppColors.Background.primary)
}

#Preview("Error State - Request Timeout", traits: .sizeThatFitsLayout) {
    ErrorStateView(
        error: MockErrorType(type: "requestTimeout"),
        message: "The request took too long. Please check your connection and try again.",
        retryButtonLabel: "Try Again",
        onRetry: {}
    )
    .background(AppColors.Background.primary)
}

#Preview("Error State - No Connectivity", traits: .sizeThatFitsLayout) {
    ErrorStateView(
        error: MockErrorType(type: "noConnectivity"),
        message: "No internet connection. Please check your network and try again.",
        retryButtonLabel: "Retry",
        onRetry: {}
    )
    .background(AppColors.Background.primary)
}

#Preview("Error State - Unexpected Error", traits: .sizeThatFitsLayout) {
    ErrorStateView(
        error: MockErrorType(type: "unexpectedError"),
        message: "An unexpected error occurred. Please try again later.",
        retryButtonLabel: "Retry",
        onRetry: {}
    )
    .background(AppColors.Background.primary)
}
