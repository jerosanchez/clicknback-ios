import Foundation

public enum CashbackType: String, Codable, Equatable {
    case percent
    case fixed
}

public struct Offer: Codable, Equatable {
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
}
