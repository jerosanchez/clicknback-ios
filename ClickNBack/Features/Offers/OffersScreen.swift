//

import SwiftUI

struct OffersScreen: View {
    @State var viewModel: OffersViewModel

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(L10nKey.Offers.Screen.title)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        // Always render the same ScrollView when offers are visible by using a
        // single `if let` branch. A @ViewBuilder switch gives each case a
        // distinct structural position, so transitioning .loaded → .loadingMore
        // → .loaded would destroy and recreate the ScrollView, resetting scroll.
        if let offers = viewModel.visibleOffers {
            offersListView(offers: offers, hasMore: viewModel.hasMore, isLoadingMore: viewModel.isLoadingMore)
        } else {
            switch viewModel.state {
            case .loading:
                OffersSkeletonView()
            case .empty:
                ScrollView {
                    offersEmptyStateView()
                }
                .refreshable {
                    await viewModel.refresh()
                }
            case .error(let error):
                ScrollView {
                    ErrorStateView(
                        error: error,
                        message: String(localized: L10nKey.Offers.Error.message),
                        retryButtonLabel: String(localized: L10nKey.Offers.Error.retryButton),
                        onRetry: { await viewModel.refresh() }
                    )
                }
            default:
            // TODO: track this situation with telemetry
            // The .loaded → .loadingMore → .loaded state transition is already 
            // handled by the single `if let` branch above, so we should never hit 
            // the .loadingMore or .refreshing states here. 
                EmptyView()
            }
        }
    }

    // MARK: - Subviews

    private func offersEmptyStateView() -> some View {
        EmptyStateView(
            imageSystemName: "tag",
            title: String(localized: L10nKey.Offers.EmptyState.title),
            message: String(localized: L10nKey.Offers.EmptyState.message)
        )
    }

    private func offersListView(offers: [Offer], hasMore: Bool, isLoadingMore: Bool) -> some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.compact) {
                ForEach(offers, id: \.id) { offer in
                    OfferRowView(offer: offer)
                        .contentShape(Rectangle())
                        .onTapGesture {}
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
    PreviewContainer.offersScreen()
}

#Preview("Empty") {
    PreviewContainer.offersScreenEmpty()
}

#Preview("No Connectivity") {
    PreviewContainer.offersScreenNoConnectivity()
}
