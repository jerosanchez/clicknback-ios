//

import SwiftUI

public struct PillButton: View {
    let label: String
    let action: () async -> Void
    @State private var isLoading = false

    public init(label: String, action: @escaping () async -> Void) {
        self.label = label
        self.action = action
    }

    public var body: some View {
        Button(action: handleTap) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
            } else {
                Text(label)
                    .font(AppTypography.Label.large)
                    .fontWeight(.semibold)
            }
        }
        .frame(height: AppDimensions.Button.height)
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .background(AppColors.Semantic.primary)
        .cornerRadius(AppDimensions.Button.cornerRadius)
        .disabled(isLoading)
    }

    private func handleTap() {
        Task {
            isLoading = true
            defer { isLoading = false }
            await action()
        }
    }
}

#Preview("PillButton - Normal") {
    VStack(spacing: AppSpacing.large) {
        PillButton(label: "Retry", action: {})
        PillButton(label: "Try Again", action: {})
    }
    .padding(AppSpacing.large)
    .background(AppColors.Background.primary)
}