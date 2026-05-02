import Foundation

public enum CashbackType: String, Codable {
    case percent
    case fixed
}

public struct Offer: Codable {
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

extension CashbackType: Equatable {
    public nonisolated static func == (lhs: CashbackType, rhs: CashbackType) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

extension Offer: Equatable {
    public nonisolated static func == (lhs: Offer, rhs: Offer) -> Bool {
        lhs.id == rhs.id &&
        lhs.merchantName == rhs.merchantName &&
        lhs.cashbackType == rhs.cashbackType &&
        lhs.cashbackValue == rhs.cashbackValue &&
        lhs.monthlyCap == rhs.monthlyCap &&
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate
    }
}
