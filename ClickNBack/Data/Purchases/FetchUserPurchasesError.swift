public enum FetchUserPurchasesError: Error, Equatable {
    case unauthorized
    case serverError
    case requestTimeout
    case noConnectivity
    case unexpectedError
}
