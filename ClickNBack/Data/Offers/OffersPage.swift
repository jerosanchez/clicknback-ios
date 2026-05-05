public struct OffersPage: Equatable {
    public let offers: [Offer]
    public let pagination: Pagination

    public init(offers: [Offer], pagination: Pagination) {
        self.offers = offers
        self.pagination = pagination
    }
}
