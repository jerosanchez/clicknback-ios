//

import SwiftUI

struct PurchaseRowView: View {
    let purchase: Purchase

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            merchantIcon

            VStack(alignment: .leading, spacing: AppSpacing.compact) {
                HStack {
                    Text(purchase.merchantName)
                        .font(AppTypography.Headline.small)
                        .foregroundStyle(AppColors.Text.primary)

                    Spacer(minLength: 0)

                    Text(formattedAmount)
                        .font(AppTypography.Label.large)
                        .foregroundStyle(AppColors.Text.primary)
                }

                HStack(spacing: AppSpacing.compact) {
                    statusBadge

                    Spacer(minLength: 0)

                    Text(formattedDate)
                        .font(AppTypography.Caption.medium)
                        .foregroundStyle(AppColors.Text.tertiary)
                }

                if purchase.cashbackStatus != nil {
                    cashbackRow
                }
            }
        }
        .padding(AppSpacing.medium)
        .background(AppColors.Background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.large)
                .stroke(AppColors.Border.border, lineWidth: AppDimensions.Border.small)
        )
    }

    // MARK: - Subviews

    private var merchantIcon: some View {
        RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.medium)
            .fill(AppColors.Background.tertiary)
            .frame(width: 48, height: 48)
            .overlay(
                Image(systemName: "bag")
                    .foregroundStyle(AppColors.Text.disabled)
            )
    }

    private var statusBadge: some View {
        Text(statusLabel)
            .font(AppTypography.Label.medium)
            .foregroundStyle(statusColor)
            .padding(.horizontal, AppSpacing.compact)
            .padding(.vertical, AppSpacing.minimal)
            .background(statusColor.opacity(0.12))
            .clipShape(Capsule())
    }

    private var cashbackRow: some View {
        HStack(spacing: AppSpacing.compact) {
            Text(String(localized: L10nKey.Purchases.Row.cashbackLabel))
                .font(AppTypography.Caption.medium)
                .foregroundStyle(AppColors.Text.secondary)

            Text(formattedCashbackAmount)
                .font(AppTypography.Label.medium)
                .foregroundStyle(AppColors.Status.success)

            if let cashbackStatus = purchase.cashbackStatus {
                Text("· \(cashbackStatus)")
                    .font(AppTypography.Caption.medium)
                    .foregroundStyle(AppColors.Text.tertiary)
            }
        }
    }

    // MARK: - Formatting

    private var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter.string(from: purchase.amount as NSDecimalNumber) ?? "\(purchase.amount)"
    }

    private var formattedCashbackAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter.string(from: purchase.cashbackAmount as NSDecimalNumber) ?? "\(purchase.cashbackAmount)"
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: purchase.createdAt)
    }

    private var statusLabel: String {
        switch purchase.status {
        case .pending:   String(localized: L10nKey.Purchases.Status.pending)
        case .confirmed: String(localized: L10nKey.Purchases.Status.confirmed)
        case .reversed:  String(localized: L10nKey.Purchases.Status.reversed)
        case .rejected:  String(localized: L10nKey.Purchases.Status.rejected)
        }
    }

    private var statusColor: Color {
        switch purchase.status {
        case .pending:   AppColors.Status.warning
        case .confirmed: AppColors.Status.success
        case .reversed:  AppColors.Text.secondary
        case .rejected:  AppColors.Status.error
        }
    }
}

#Preview {
    PreviewContainer.purchaseRowView()
}
