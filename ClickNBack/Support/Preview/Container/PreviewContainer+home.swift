//

import SwiftUI

extension PreviewContainer {
    static func homeScreen(
        fetchActiveHandler: FetchActiveHandler? = nil,
        appLanguage: AppLanguage = .english
    ) -> some View {
        let offersRepository = MockOffersRepository()
        offersRepository.fetchActiveHandler = fetchActiveHandler

        let cache = MockKeyValueStorage()

        return HomeScreen()
            .environment(\.locale, appLanguage.locale)
    }
}
