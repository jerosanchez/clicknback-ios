import Foundation

public struct UserPurchaseResponse: Decodable {
    public let id: String
    public let merchantName: String
    public let amount: String
    public let status: String
    public let cashbackAmount: String
    public let cashbackStatus: String?
    public let createdAt: String

    public init(
        id: String,
        merchantName: String,
        amount: String,
        status: String,
        cashbackAmount: String,
        cashbackStatus: String?,
        createdAt: String
    ) {
        self.id = id
        self.merchantName = merchantName
        self.amount = amount
        self.status = status
        self.cashbackAmount = cashbackAmount
        self.cashbackStatus = cashbackStatus
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case merchantName    = "merchant_name"
        case amount
        case status
        case cashbackAmount  = "cashback_amount"
        case cashbackStatus  = "cashback_status"
        case createdAt       = "created_at"
    }
}
