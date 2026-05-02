//

import SwiftUI

struct OffersContainer: View {
    var body: some View {
        OffersScreen(
            viewModel: OffersViewModel(
                fetchOffersUseCase: FetchActiveOffersUseCase(
                    offersRepository: CompositionRoot.offersRepository,
                    offersCache: CompositionRoot.settingsStorage
                ),
                getCachedOffersUseCase: GetCachedOffersUseCase(
                    offersCache: CompositionRoot.settingsStorage
                ),
                analyticsTracker: CompositionRoot.analyticsTracker
            )
        )
    }
}
