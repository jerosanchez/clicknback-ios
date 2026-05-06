//

import SwiftUI

struct PurchasesContainer: View {
    var body: some View {
        PurchasesScreen(
            viewModel: PurchasesViewModel(
                fetchPurchasesUseCase: FetchUserPurchasesUseCase(
                    purchasesRepository: CompositionRoot.purchasesRepository
                ),
                analyticsTracker: CompositionRoot.analyticsTracker
            )
        )
    }
}
