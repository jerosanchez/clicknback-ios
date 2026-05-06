//

import SwiftUI

struct PurchasesSkeletonView: View {
    @State private var isAnimating = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.compact) {
                ForEach(0..<6, id: \.self) { _ in
                    skeletonRow
                }
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.vertical, AppSpacing.compact)
        }
        .onAppear { isAnimating = true }
    }

    private var skeletonRow: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.medium)
                .fill(AppColors.Background.tertiary)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: AppSpacing.compact) {
                HStack {
                    RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.small)
                        .fill(AppColors.Background.tertiary)
                        .frame(width: 120, height: 16)

                    Spacer(minLength: 0)

                    RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.small)
                        .fill(AppColors.Background.tertiary)
                        .frame(width: 60, height: 16)
                }

                HStack {
                    RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.full)
                        .fill(AppColors.Background.tertiary)
                        .frame(width: 80, height: 22)

                    Spacer(minLength: 0)

                    RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.small)
                        .fill(AppColors.Background.tertiary)
                        .frame(width: 70, height: 12)
                }

                RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.small)
                    .fill(AppColors.Background.tertiary)
                    .frame(width: 100, height: 12)
            }
        }
        .padding(AppSpacing.medium)
        .background(AppColors.Background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.large)
                .stroke(AppColors.Border.border, lineWidth: AppDimensions.Border.small)
        )
        .modifier(ShimmerModifier(isAnimating: isAnimating))
    }
}

#Preview {
    PurchasesSkeletonView()
}
