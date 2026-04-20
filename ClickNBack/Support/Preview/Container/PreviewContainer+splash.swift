//

import SwiftUI

extension PreviewContainer {
    static func splashScreen(
        appLanguage: AppLanguage = .english
    ) -> some View {
        SplashScreen(
            viewModel: SplashViewModel(
                analyticsTracker: MockAnalyticsTracker()
            )
        )
        .environment(\.locale, appLanguage.locale)
    }
}
