extension Offer {
    public static var mock: Offer {
        Offer(
            id: "offer-1",
            merchantName: "Amazon",
            cashbackType: .percent,
            cashbackValue: 10.0,
            monthlyCap: 50.0,
            startDate: "2026-01-01",
            endDate: "2026-12-31"
        )
    }
}
