import Foundation

public struct ActiveOfferResponse: Decodable {
    public let id: String
    public let merchantName: String
    public let cashbackType: CashbackType
    public let cashbackValue: Double
    public let monthlyCap: Double
    public let startDate: String
    public let endDate: String

    public init(
        id: String,
        merchantName: String,
        cashbackType: CashbackType,
        cashbackValue: Double,
        monthlyCap: Double,
        startDate: String,
        endDate: String
    ) {
        self.id = id
        self.merchantName = merchantName
        self.cashbackType = cashbackType
        self.cashbackValue = cashbackValue
        self.monthlyCap = monthlyCap
        self.startDate = startDate
        self.endDate = endDate
    }

    enum CodingKeys: String, CodingKey {
        case id
        case merchantName  = "merchant_name"
        case cashbackType  = "cashback_type"
        case cashbackValue = "cashback_value"
        case monthlyCap    = "monthly_cap"
        case startDate     = "start_date"
        case endDate       = "end_date"
    }
}
