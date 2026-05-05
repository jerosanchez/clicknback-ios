import Foundation

public struct Purchase: Equatable {
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
