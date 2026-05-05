public struct PurchasesPage: Equatable {
    public let purchases: [Purchase]
    public let pagination: Pagination

    public init(purchases: [Purchase], pagination: Pagination) {
        self.purchases = purchases
        self.pagination = pagination
    }
}
