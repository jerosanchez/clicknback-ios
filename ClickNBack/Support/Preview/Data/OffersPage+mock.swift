extension OffersPage {
    public static var mock: OffersPage {
        OffersPage(
            offers: .mock,
            pagination: Pagination(offset: 0, limit: 20, total: 1)
        )
    }
}
