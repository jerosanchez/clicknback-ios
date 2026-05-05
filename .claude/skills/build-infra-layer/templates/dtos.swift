// MARK: - Item DTO
// File: ClickNBack/Infra/Repositories/<Feature>/<Model>Response.swift
//
// Rules:
// - Decodable only (never Codable unless this type is also sent back)
// - CodingKeys for every snake_case → camelCase field
// - Monetary amounts stay String — mapper converts to Decimal
// - Dates stay String — mapper parses with ISO8601DateFormatter
// - Status fields stay String — mapper converts to the typed enum

import Foundation

public struct <Model>Response: Decodable {
    public let id: String
    public let merchantName: String
    public let amount: String          // Decimal string from API — mapper converts to Decimal
    public let status: String          // Raw string — mapper converts to <Model>Status enum
    public let cashbackAmount: String  // Decimal string from API
    public let cashbackStatus: String? // Optional: nil when API returns null
    public let createdAt: String       // ISO 8601 string — mapper parses to Date

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
        case merchantName   = "merchant_name"
        case amount
        case status
        case cashbackAmount = "cashback_amount"
        case cashbackStatus = "cashback_status"
        case createdAt      = "created_at"
    }
}

// MARK: - Paginated Response Wrapper
// File: ClickNBack/Infra/Repositories/<Feature>/Paginated<Model>sResponse.swift
//
// Reuse PaginationResponse from ClickNBack/Infra/Repositories/Shared/PaginationResponse.swift.
// Only add this wrapper if the endpoint is paginated.

public struct Paginated<Model>sResponse: Decodable {
    public let data: [<Model>Response]
    public let pagination: PaginationResponse

    public init(data: [<Model>Response], pagination: PaginationResponse) {
        self.data = data
        self.pagination = pagination
    }
}

// MARK: - Shared DTO (extract to Shared/ when used by ≥2 feature repositories)
// File: ClickNBack/Infra/Repositories/Shared/PaginationResponse.swift  (already exists)
//
// public struct PaginationResponse: Decodable {
//     public let offset: Int
//     public let limit: Int
//     public let total: Int
// }
