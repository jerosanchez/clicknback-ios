//

import SwiftUI

struct OfferRowView: View {
    let offer: Offer

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            imagePlaceholder

            VStack(alignment: .leading, spacing: AppSpacing.compact) {
                Text(offer.merchantName)
                    .font(AppTypography.Headline.small)
                    .foregroundStyle(AppColors.Text.primary)

                cashbackBadge

                HStack(spacing: AppSpacing.compact) {
                    Text(offer.startDate)
                        .font(AppTypography.Caption.medium)
                        .foregroundStyle(AppColors.Text.tertiary)

                    Text("–")
                        .font(AppTypography.Caption.medium)
                        .foregroundStyle(AppColors.Text.tertiary)

                    Text(offer.endDate)
                        .font(AppTypography.Caption.medium)
                        .foregroundStyle(AppColors.Text.tertiary)
                }

                Text("Cap: \(formattedCap)")
                    .font(AppTypography.Caption.medium)
                    .foregroundStyle(AppColors.Text.secondary)
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
    }

    // MARK: - Private

    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.medium)
            .fill(AppColors.Background.tertiary)
            .frame(width: 64, height: 64)
            .overlay(
                Image(systemName: "tag")
                    .foregroundStyle(AppColors.Text.disabled)
            )
    }

    private var cashbackBadge: some View {
        Text(formattedCashback)
            .font(AppTypography.Label.medium)
            .foregroundStyle(AppColors.Status.success)
            .padding(.horizontal, AppSpacing.compact)
            .padding(.vertical, AppSpacing.minimal)
            .background(AppColors.Status.success.opacity(0.12))
            .clipShape(Capsule())
    }

    private var formattedCashback: String {
        switch offer.cashbackType {
        case .percent:
            let value = offer.cashbackValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(offer.cashbackValue))
                : String(offer.cashbackValue)
            return "\(value)% cashback"
        case .fixed:
            let value = offer.cashbackValue.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(offer.cashbackValue))
                : String(offer.cashbackValue)
            return "€\(value) cashback"
        }
    }

    private var formattedCap: String {
        let value = offer.monthlyCap.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(offer.monthlyCap))
            : String(offer.monthlyCap)
        return "€\(value)/month"
    }
}

#Preview {
    PreviewContainer.offerRowView()
}
