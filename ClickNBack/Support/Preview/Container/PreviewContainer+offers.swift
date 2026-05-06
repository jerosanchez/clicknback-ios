//

import SwiftUI

extension PreviewContainer {
    static func offersScreen(
        fetchActiveHandler: FetchActiveHandler? = nil,
        appLanguage: AppLanguage = .english
    ) -> some View {
        let offersRepository = MockOffersRepository()
        offersRepository.fetchActiveHandler = fetchActiveHandler

        let cache = MockKeyValueStorage()

        return OffersScreen(
            viewModel: OffersViewModel(
                fetchOffersUseCase: FetchActiveOffersUseCase(
                    offersRepository: offersRepository,
                    offersCache: cache
                ),
                getCachedOffersUseCase: GetCachedOffersUseCase(
                    offersCache: cache
                ),
                analyticsTracker: MockAnalyticsTracker()
            )
        )
        .environment(\.locale, appLanguage.locale)
    }

    static func offersScreenEmpty(
        appLanguage: AppLanguage = .english
    ) -> some View {
        offersScreen(
            fetchActiveHandler: { _, _ in
                .success(OffersPage(offers: [], pagination: Pagination(offset: 0, limit: 20, total: 0)))
            },
            appLanguage: appLanguage
        )
    }

    static func offersScreenNoConnectivity(
        appLanguage: AppLanguage = .english
    ) -> some View {
        offersScreen(
            fetchActiveHandler: { _, _ in .failure(.noConnectivity) },
            appLanguage: appLanguage
        )
    }

    static func offerRowView(
        offer: Offer = .mock,
        appLanguage: AppLanguage = .english
    ) -> some View {
        OfferRowView(offer: offer)
            .padding(AppSpacing.medium)
            .environment(\.locale, appLanguage.locale)
    }
}
