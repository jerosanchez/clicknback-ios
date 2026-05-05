extension PurchasesPage {
    public static var mock: PurchasesPage {
        PurchasesPage(
            purchases: .mock,
            pagination: Pagination(offset: 0, limit: 10, total: 3)
        )
    }
}
