//

import SwiftUI

struct SplashContainer: View {
    var body: some View {
        SplashScreen(
            viewModel: SplashViewModel(
                analyticsTracker: CompositionRoot.analyticsTracker
            )
        )
    }
}
