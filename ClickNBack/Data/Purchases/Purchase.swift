import Foundation

public struct Purchase {
    public let id: String
    public let merchantName: String
    public let amount: Decimal
    public let status: PurchaseStatus
    public let cashbackAmount: Decimal
    public let cashbackStatus: String?
    public let createdAt: Date

    public init(
        id: String,
        merchantName: String,
        amount: Decimal,
        status: PurchaseStatus,
        cashbackAmount: Decimal,
        cashbackStatus: String?,
        createdAt: Date
    ) {
        self.id = id
        self.merchantName = merchantName
        self.amount = amount
        self.status = status
        self.cashbackAmount = cashbackAmount
        self.cashbackStatus = cashbackStatus
        self.createdAt = createdAt
    }
}

extension Purchase: Equatable {
    public nonisolated static func == (lhs: Purchase, rhs: Purchase) -> Bool {
        lhs.id == rhs.id &&
        lhs.merchantName == rhs.merchantName &&
        lhs.amount == rhs.amount &&
        lhs.status == rhs.status &&
        lhs.cashbackAmount == rhs.cashbackAmount &&
        lhs.cashbackStatus == rhs.cashbackStatus &&
        lhs.createdAt == rhs.createdAt
    }
}
