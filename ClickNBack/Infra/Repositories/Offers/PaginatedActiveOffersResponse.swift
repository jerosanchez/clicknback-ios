import Foundation

public struct PaginatedActiveOffersResponse: Decodable {
    public let data: [ActiveOfferResponse]
    public let pagination: PaginationResponse

    public init(data: [ActiveOfferResponse], pagination: PaginationResponse) {
        self.data = data
        self.pagination = pagination
    }
}
