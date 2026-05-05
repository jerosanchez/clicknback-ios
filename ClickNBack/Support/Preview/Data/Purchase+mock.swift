import Foundation

extension Purchase {
    public static var mock: Purchase {
        Purchase(
            id: "550e8400-e29b-41d4-a716-446655440000",
            merchantName: "Amazon",
            amount: 25.99,
            status: .confirmed,
            cashbackAmount: 2.60,
            cashbackStatus: "confirmed",
            createdAt: Date(timeIntervalSince1970: 1_746_057_600)
        )
    }
}

extension Array where Element == Purchase {
    public static var mock: [Purchase] {
        [
            Purchase(
                id: "550e8400-e29b-41d4-a716-446655440000",
                merchantName: "Amazon",
                amount: 25.99,
                status: .confirmed,
                cashbackAmount: 2.60,
                cashbackStatus: "confirmed",
                createdAt: Date(timeIntervalSince1970: 1_746_057_600)
            ),
            Purchase(
                id: "550e8400-e29b-41d4-a716-446655440001",
                merchantName: "Starbucks",
                amount: 8.50,
                status: .pending,
                cashbackAmount: 0.85,
                cashbackStatus: "pending",
                createdAt: Date(timeIntervalSince1970: 1_746_144_000)
            ),
            Purchase(
                id: "550e8400-e29b-41d4-a716-446655440002",
                merchantName: "Apple Store",
                amount: 149.00,
                status: .reversed,
                cashbackAmount: 14.90,
                cashbackStatus: nil,
                createdAt: Date(timeIntervalSince1970: 1_746_230_400)
            )
        ]
    }
}
