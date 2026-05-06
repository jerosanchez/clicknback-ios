//

import SwiftUI

struct PurchasesScreen: View {
    @State var viewModel: PurchasesViewModel

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(L10nKey.Purchases.Screen.title)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        // Always render the same ScrollView when purchases are visible by using a
        // single `if let` branch. A @ViewBuilder switch gives each case a
        // distinct structural position, so transitioning .loaded → .loadingMore
        // → .loaded would destroy and recreate the ScrollView, resetting scroll.
        if let purchases = viewModel.visiblePurchases {
            purchasesListView(
                purchases: purchases,
                hasMore: viewModel.hasMore,
                isLoadingMore: viewModel.isLoadingMore
            )
        } else {
            switch viewModel.state {
            case .loading:
                PurchasesSkeletonView()
            case .empty:
                ScrollView {
                    purchasesEmptyStateView()
                }
                .refreshable {
                    await viewModel.refresh()
                }
            case .error(let error):
                ScrollView {
                    ErrorStateView(
                        error: error,
                        message: String(localized: L10nKey.Purchases.Error.message),
                        retryButtonLabel: String(localized: L10nKey.Purchases.Error.retryButton),
                        onRetry: { await viewModel.refresh() }
                    )
                }
            default:
                EmptyView()
            }
        }
    }

    // MARK: - Subviews

    private func purchasesEmptyStateView() -> some View {
        EmptyStateView(
            imageSystemName: "bag",
            title: String(localized: L10nKey.Purchases.EmptyState.title),
            message: String(localized: L10nKey.Purchases.EmptyState.message)
        )
    }

    private func purchasesListView(purchases: [Purchase], hasMore: Bool, isLoadingMore: Bool) -> some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.compact) {
                ForEach(purchases, id: \.id) { purchase in
                    PurchaseRowView(purchase: purchase)
                }

                if isLoadingMore {
                    ProgressView()
                        .padding(.vertical, AppSpacing.medium)
                } else if hasMore {
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            Task { await viewModel.loadMore() }
                        }
                }
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.vertical, AppSpacing.compact)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

#Preview("Success") {
    PreviewContainer.purchasesScreen()
}

#Preview("Empty") {
    PreviewContainer.purchasesScreenEmpty()
}

#Preview("No Connectivity") {
    PreviewContainer.purchasesScreenNoConnectivity()
}
