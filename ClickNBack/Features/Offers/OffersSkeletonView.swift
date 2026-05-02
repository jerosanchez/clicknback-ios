//

import SwiftUI

struct OffersSkeletonView: View {
    @State private var isAnimating = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.compact) {
                ForEach(0..<5, id: \.self) { _ in
                    skeletonCard
                }
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.vertical, AppSpacing.compact)
        }
        .onAppear { isAnimating = true }
    }

    private var skeletonCard: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.medium)
                .fill(AppColors.Background.tertiary)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: AppSpacing.compact) {
                RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.small)
                    .fill(AppColors.Background.tertiary)
                    .frame(width: 140, height: 16)

                RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.full)
                    .fill(AppColors.Background.tertiary)
                    .frame(width: 100, height: 22)

                RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.small)
                    .fill(AppColors.Background.tertiary)
                    .frame(width: 120, height: 12)

                RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.small)
                    .fill(AppColors.Background.tertiary)
                    .frame(width: 80, height: 12)
            }

            Spacer(minLength: 0)
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
    OffersSkeletonView()
}
