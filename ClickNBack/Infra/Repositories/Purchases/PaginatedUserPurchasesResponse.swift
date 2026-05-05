import Foundation

public struct PaginatedUserPurchasesResponse: Decodable {
    public let data: [UserPurchaseResponse]
    public let pagination: PaginationResponse

    public init(data: [UserPurchaseResponse], pagination: PaginationResponse) {
        self.data = data
        self.pagination = pagination
    }
}
