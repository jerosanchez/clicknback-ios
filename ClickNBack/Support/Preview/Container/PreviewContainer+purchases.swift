//

import SwiftUI

extension PreviewContainer {
    static func purchasesScreen(
        fetchUserPurchasesHandler: FetchUserPurchasesHandler? = nil,
        appLanguage: AppLanguage = .english
    ) -> some View {
        let purchasesRepository = MockPurchasesRepository()
        purchasesRepository.fetchUserPurchasesHandler = fetchUserPurchasesHandler

        return PurchasesScreen(
            viewModel: PurchasesViewModel(
                fetchPurchasesUseCase: FetchUserPurchasesUseCase(
                    purchasesRepository: purchasesRepository
                ),
                analyticsTracker: MockAnalyticsTracker()
            )
        )
        .environment(\.locale, appLanguage.locale)
    }

    static func purchasesScreenEmpty(
        appLanguage: AppLanguage = .english
    ) -> some View {
        purchasesScreen(
            fetchUserPurchasesHandler: { _, _ in
                .success(PurchasesPage(purchases: [], pagination: Pagination(offset: 0, limit: 10, total: 0)))
            },
            appLanguage: appLanguage
        )
    }

    static func purchasesScreenNoConnectivity(
        appLanguage: AppLanguage = .english
    ) -> some View {
        purchasesScreen(
            fetchUserPurchasesHandler: { _, _ in .failure(.noConnectivity) },
            appLanguage: appLanguage
        )
    }

    static func purchaseRowView(
        purchase: Purchase = .mock,
        appLanguage: AppLanguage = .english
    ) -> some View {
        PurchaseRowView(purchase: purchase)
            .padding(AppSpacing.medium)
            .environment(\.locale, appLanguage.locale)
    }
}
