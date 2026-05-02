//

import Foundation

extension FetchActiveOffersError: ErrorStateViewErrorType {
    public var errorStateIconName: String {
        switch self {
        case .unauthorized:
            return AppIcons.ErrorState.unauthorized
        case .serverError:
            return AppIcons.ErrorState.serverError
        case .requestTimeout:
            return AppIcons.ErrorState.requestTimeout
        case .noConnectivity:
            return AppIcons.ErrorState.noConnectivity
        case .unexpectedError:
            return AppIcons.ErrorState.unexpectedError
        }
    }
}
