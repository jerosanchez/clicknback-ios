public struct OffersPage: Equatable {
    public let offers: [Offer]
    public let pagination: OffersPagination

    public init(offers: [Offer], pagination: OffersPagination) {
        self.offers = offers
        self.pagination = pagination
    }
}
