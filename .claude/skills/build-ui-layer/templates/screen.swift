// MARK: - Screen
// File: ClickNBack/Features/<Feature>/<Screen>Screen.swift

import SwiftUI

struct <Screen>Screen: View {
    @State var viewModel: <Screen>ViewModel

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(L10nKey.<Feature>.Screen.title)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        // Always render the same ScrollView when items are visible by using a
        // single `if let` branch. A @ViewBuilder switch gives each case a
        // distinct structural position, so transitioning .loaded → .loadingMore
        // → .loaded would destroy and recreate the ScrollView, resetting scroll.
        if let items = viewModel.visible<Models> {
            <feature>ListView(
                items: items,
                hasMore: viewModel.hasMore,
                isLoadingMore: viewModel.isLoadingMore
            )
        } else {
            switch viewModel.state {
            case .loading:
                <Screen>SkeletonView()
            case .empty:
                ScrollView {
                    <feature>EmptyStateView()
                }
                .refreshable {
                    await viewModel.refresh()
                }
            case .error(let error):
                ScrollView {
                    ErrorStateView(
                        error: error,
                        message: String(localized: L10nKey.<Feature>.Error.message),
                        retryButtonLabel: String(localized: L10nKey.<Feature>.Error.retryButton),
                        onRetry: { await viewModel.refresh() }
                    )
                }
            default:
                EmptyView()
            }
        }
    }

    // MARK: - Subviews

    private func <feature>EmptyStateView() -> some View {
        EmptyStateView(
            imageSystemName: "<system-image>",  // e.g. "bag.slash", "tag.slash"
            title: String(localized: L10nKey.<Feature>.EmptyState.title),
            message: String(localized: L10nKey.<Feature>.EmptyState.message)
        )
    }

    private func <feature>ListView(items: [<Model>], hasMore: Bool, isLoadingMore: Bool) -> some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.compact) {
                ForEach(items, id: \.id) { item in
                    <Model>RowView(item: item)
                }

                if isLoadingMore {
                    ProgressView()
                        .padding(.vertical, AppSpacing.medium)
                } else if hasMore {
                    // Invisible 1pt trigger — fires loadMore() as the user approaches the bottom
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

#Preview {
    PreviewContainer.<feature>Screen()
}

// MARK: - Row / Card View
// File: ClickNBack/Features/<Feature>/<Model>RowView.swift

import SwiftUI

struct <Model>RowView: View {
    let item: <Model>

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            itemIcon

            VStack(alignment: .leading, spacing: AppSpacing.compact) {
                Text(item.title)
                    .font(AppTypography.Headline.small)
                    .foregroundStyle(AppColors.Text.primary)

                statusBadge

                Text(formattedDate)
                    .font(AppTypography.Caption.medium)
                    .foregroundStyle(AppColors.Text.tertiary)
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

    private var itemIcon: some View {
        RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.medium)
            .fill(AppColors.Background.tertiary)
            .frame(width: 48, height: 48)
            .overlay(
                Image(systemName: "<system-image>")
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

    private var statusLabel: String {
        // Map each status case to a localized string
        // e.g. String(localized: L10nKey.<Feature>.Status.pending)
        ""
    }

    private var statusColor: Color {
        // Map each status case to an AppColors.Status token
        // e.g. .pending → AppColors.Status.warning
        .clear
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: item.createdAt)
    }
}

#Preview {
    PreviewContainer.<feature>RowView()
}

// MARK: - Skeleton View
// File: ClickNBack/Features/<Feature>/<Screen>SkeletonView.swift
// Mirrors the real row/card layout using filled RoundedRectangle shapes + ShimmerModifier.

import SwiftUI

struct <Screen>SkeletonView: View {
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
                RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.small)
                    .fill(AppColors.Background.tertiary)
                    .frame(width: 140, height: 16)

                RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.full)
                    .fill(AppColors.Background.tertiary)
                    .frame(width: 80, height: 22)

                RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.small)
                    .fill(AppColors.Background.tertiary)
                    .frame(width: 100, height: 12)
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

// MARK: - Analytics Event Enum
// File: ClickNBack/Features/<Feature>/<Feature>AnalyticsEvent.swift

import Foundation

enum <Feature>AnalyticsEvent: AnalyticsEvent {
    case screenShowed
    // Add one case per tracked interaction

    var name: String {
        switch self {
        case .screenShowed: "<feature>-screen-showed"   // kebab-case
        }
    }

    var properties: [String: Any] {
        switch self {
        case .screenShowed: [:]
        }
    }
}

// MARK: - L10n Keys
// File: ClickNBack/Features/<Feature>/L10nKey+<feature>.swift

import Foundation

// swiftlint:disable nesting
extension L10nKey {
    enum <Feature> {
        enum Screen {
            static let title = LocalizedStringResource("<feature>.screen.title", table: "<Feature>")
        }
        enum EmptyState {
            static let title   = LocalizedStringResource("<feature>.emptyState.title",   table: "<Feature>")
            static let message = LocalizedStringResource("<feature>.emptyState.message", table: "<Feature>")
        }
        enum Error {
            static let message     = LocalizedStringResource("<feature>.error.message",     table: "<Feature>")
            static let retryButton = LocalizedStringResource("<feature>.error.retryButton", table: "<Feature>")
        }
        // Add additional key groups for row labels, status strings, etc.
    }
}
// swiftlint:enable nesting

// MARK: - String Catalog
// File: ClickNBack/Features/<Feature>/<Feature>.xcstrings
// Use extractionState: "manual" for all keys.
// Always include at least English ("en") and Spanish ("es") translations.
// See Offers.xcstrings for the exact JSON structure to follow.

// MARK: - ErrorStateView Conformance
// File: ClickNBack/Data/<Feature>/<Fetch>Error+ErrorStateView.swift

import Foundation

extension Fetch<Model>Error: ErrorStateViewErrorType {
    public var errorStateIconName: String {
        switch self {
        case .unauthorized:    AppIcons.ErrorState.unauthorized
        case .serverError:     AppIcons.ErrorState.serverError
        case .requestTimeout:  AppIcons.ErrorState.requestTimeout
        case .noConnectivity:  AppIcons.ErrorState.noConnectivity
        case .unexpectedError: AppIcons.ErrorState.unexpectedError
        }
    }
}

// MARK: - Composition Container
// File: ClickNBack/Main/Composition/<Screen>Container.swift

import SwiftUI

struct <Screen>Container: View {
    var body: some View {
        <Screen>Screen(
            viewModel: <Screen>ViewModel(
                fetch<Models>UseCase: Fetch<Model>UseCase(
                    <feature>Repository: CompositionRoot.<feature>Repository
                ),
                analyticsTracker: CompositionRoot.analyticsTracker
            )
        )
    }
}

// MARK: - Preview Container Extension
// File: ClickNBack/Support/Preview/Container/PreviewContainer+<feature>.swift

import SwiftUI

extension PreviewContainer {
    static func <feature>Screen(
        fetch<Model>Handler: Fetch<Model>Handler? = nil,
        appLanguage: AppLanguage = .english
    ) -> some View {
        let repository = Mock<Feature>Repository()
        repository.fetch<Model>Handler = fetch<Model>Handler

        return <Screen>Screen(
            viewModel: <Screen>ViewModel(
                fetch<Models>UseCase: Fetch<Model>UseCase(
                    <feature>Repository: repository
                ),
                analyticsTracker: MockAnalyticsTracker()
            )
        )
        .environment(\.locale, appLanguage.locale)
    }

    static func <feature>RowView(
        <model>: <Model> = .mock,
        appLanguage: AppLanguage = .english
    ) -> some View {
        <Model>RowView(<model>: <model>)
            .padding(AppSpacing.medium)
            .environment(\.locale, appLanguage.locale)
    }
}
