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

    static func offerCardView(
        offer: Offer = .mock,
        appLanguage: AppLanguage = .english
    ) -> some View {
        OfferCardView(offer: offer)
            .padding(AppSpacing.medium)
            .environment(\.locale, appLanguage.locale)
    }
}
