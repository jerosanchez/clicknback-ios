//

import Foundation

enum AppEnvironment {
    case production
    case staging
}

struct AppConfig {
    static var environment = AppEnvironment.production

    static var baseURL: URL {
        let urlString = switch environment {
        case .staging:
            "https://dev.clicknback.com/api"
        case .production:
            "https://clicknback.com/api/"
        }

        return URL(string: urlString)!
    }
}
