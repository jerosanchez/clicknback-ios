extension Offer {
    public static var mock: Offer {
        Offer(
            id: "offer-1",
            merchantName: "Amazon",
            cashbackType: .percent,
            cashbackValue: 10.0,
            monthlyCap: 50.0,
            startDate: "2026-03-01",
            endDate: "2026-12-31"
        )
    }
}

extension Array where Element == Offer {
    public static var mock: [Offer] {
        [
            Offer(
                id: "offer-1",
                merchantName: "Amazon",
                cashbackType: .percent,
                cashbackValue: 10.0,
                monthlyCap: 50.0,
                startDate: "2026-03-01",
                endDate: "2026-12-31"
            ),
            Offer(
                id: "offer-2",
                merchantName: "Starbucks",
                cashbackType: .fixed,
                cashbackValue: 2.0,
                monthlyCap: 20.0,
                startDate: "2026-04-15",
                endDate: "2026-09-30"
            ),
            Offer(
                id: "offer-3",
                merchantName: "Nike Store",
                cashbackType: .percent,
                cashbackValue: 15.0,
                monthlyCap: 75.0,
                startDate: "2026-02-01",
                endDate: "2026-11-30"
            ),
            Offer(
                id: "offer-4",
                merchantName: "Whole Foods Market",
                cashbackType: .percent,
                cashbackValue: 5.0,
                monthlyCap: 30.0,
                startDate: "2026-01-01",
                endDate: "2026-12-31"
            ),
            Offer(
                id: "offer-5",
                merchantName: "Uber Eats",
                cashbackType: .fixed,
                cashbackValue: 3.5,
                monthlyCap: 25.0,
                startDate: "2026-05-01",
                endDate: "2026-10-31"
            ),
            Offer(
                id: "offer-6",
                merchantName: "Best Buy",
                cashbackType: .percent,
                cashbackValue: 8.0,
                monthlyCap: 60.0,
                startDate: "2026-03-15",
                endDate: "2026-11-15"
            )
        ]
    }
}
