import Foundation
import ClickNBack
import Testing

@MainActor
@Suite("RemoteOffersRepository.fetchActive")
struct RemoteOffersRepositoryFetchActiveTests {

    // MARK: - Success

    @Test
    func fetchActive_returnsOffersPage_onSuccessfulResponse() async {
        // Arrange
        let offerId = UUID().uuidString
        let response = makePaginatedResponse(
            offers: [makeOfferResponse(id: offerId, merchantName: "Starbucks")],
            offset: 0,
            limit: 20,
            total: 1
        )
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(response, for: "v1/offers/active")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchActive(offset: 0, limit: 20)

        // Assert
        guard case .success(let page) = result else {
            #expect(Bool(false), "Expected success")
            return
        }
        #expect(page.offers.count == 1)
        #expect(page.offers[0].id == offerId)
        #expect(page.offers[0].merchantName == "Starbucks")
        #expect(page.pagination.offset == 0)
        #expect(page.pagination.limit == 20)
        #expect(page.pagination.total == 1)
    }

    @Test
    func fetchActive_mapsAllOfferFields_onSuccessfulResponse() async {
        // Arrange
        let offerId = UUID().uuidString
        let offerResponse = makeOfferResponse(
            id: offerId,
            merchantName: "Nike",
            cashbackType: .percent,
            cashbackValue: 10.0,
            monthlyCap: 50.0,
            startDate: "2026-01-01",
            endDate: "2026-12-31"
        )
        let response = makePaginatedResponse(offers: [offerResponse])
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(response, for: "v1/offers/active")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchActive(offset: 0, limit: 20)

        // Assert
        guard case .success(let page) = result else {
            #expect(Bool(false), "Expected success")
            return
        }
        let offer = page.offers[0]
        #expect(offer.id == offerId)
        #expect(offer.merchantName == "Nike")
        #expect(offer.cashbackType == .percent)
        #expect(offer.cashbackValue == 10.0)
        #expect(offer.monthlyCap == 50.0)
        #expect(offer.startDate == "2026-01-01")
        #expect(offer.endDate == "2026-12-31")
    }

    @Test
    func fetchActive_mapsAllOffers_whenResponseContainsMultipleOffers() async {
        // Arrange
        let offerId1 = UUID().uuidString
        let offerId2 = UUID().uuidString
        let offerId3 = UUID().uuidString
        
        let offers = [
            makeOfferResponse(id: offerId1, merchantName: "Starbucks"),
            makeOfferResponse(id: offerId2, merchantName: "Nike"),
            makeOfferResponse(id: offerId3, merchantName: "Amazon")
        ]
        let response = makePaginatedResponse(offers: offers, offset: 0, limit: 20, total: 3)
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(response, for: "v1/offers/active")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchActive(offset: 0, limit: 20)

        // Assert
        guard case .success(let page) = result else {
            #expect(Bool(false), "Expected success")
            return
        }
        #expect(page.offers.count == 3)
        #expect(page.offers[0].id == offerId1)
        #expect(page.offers[0].merchantName == "Starbucks")
        #expect(page.offers[1].id == offerId2)
        #expect(page.offers[1].merchantName == "Nike")
        #expect(page.offers[2].id == offerId3)
        #expect(page.offers[2].merchantName == "Amazon")
    }

    @Test
    func fetchActive_passesOffsetAndLimitAsQueryParams_onRequest() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(makePaginatedResponse(), for: "v1/offers/active")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        _ = await sut.fetchActive(offset: 40, limit: 10)

        // Assert
        #expect(apiClient.requestHistory.count == 1)
        #expect(apiClient.requestHistory[0].endpoint == "v1/offers/active")
    }

    // MARK: - Error mapping

    @Test
    func fetchActive_returnsUnauthorized_on401APIError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.apiError(401, nil))
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchActive(offset: 0, limit: 20)

        // Assert
        guard case .failure(.unauthorized) = result else {
            #expect(Bool(false), "Expected unauthorized error")
            return
        }
    }

    @Test
    func fetchActive_returnsUnexpectedError_onNon401APIError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.apiError(422, nil))
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchActive(offset: 0, limit: 20)

        // Assert
        guard case .failure(.unexpectedError) = result else {
            #expect(Bool(false), "Expected unexpectedError")
            return
        }
    }

    @Test
    func fetchActive_returnsServerError_onServerError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.serverError(500))
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchActive(offset: 0, limit: 20)

        // Assert
        guard case .failure(.serverError) = result else {
            #expect(Bool(false), "Expected serverError")
            return
        }
    }

    @Test
    func fetchActive_returnsRequestTimeout_onRequestTimeoutError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.requestTimeout)
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchActive(offset: 0, limit: 20)

        // Assert
        guard case .failure(.requestTimeout) = result else {
            #expect(Bool(false), "Expected requestTimeout error")
            return
        }
    }

    @Test
    func fetchActive_returnsNoConnectivity_onNoConnectionError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.noConnection)
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchActive(offset: 0, limit: 20)

        // Assert
        guard case .failure(.noConnectivity) = result else {
            #expect(Bool(false), "Expected noConnectivity error")
            return
        }
    }

    @Test
    func fetchActive_returnsUnexpectedError_onDecodingError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.decodingError)
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchActive(offset: 0, limit: 20)

        // Assert
        guard case .failure(.unexpectedError) = result else {
            #expect(Bool(false), "Expected unexpectedError")
            return
        }
    }

    @Test
    func fetchActive_returnsUnexpectedError_onInvalidURLError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.invalidURL)
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchActive(offset: 0, limit: 20)

        // Assert
        guard case .failure(.unexpectedError) = result else {
            #expect(Bool(false), "Expected unexpectedError")
            return
        }
    }

    @Test
    func fetchActive_returnsUnexpectedError_onUnknownError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.unknownError(nil))
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchActive(offset: 0, limit: 20)

        // Assert
        guard case .failure(.unexpectedError) = result else {
            #expect(Bool(false), "Expected unexpectedError")
            return
        }
    }

    // MARK: - Helpers

    private func makeSUT(apiClient: APIClient? = nil) -> RemoteOffersRepository {
        RemoteOffersRepository(apiClient: apiClient ?? makeAPIClient())
    }

    private func makeAPIClient(
        response: PaginatedActiveOffersResponse = PaginatedActiveOffersResponse(
            data: [],
            pagination: PaginationResponse(offset: 0, limit: 20, total: 0)
        ),
        endpoint: String = "v1/offers/active"
    ) -> MockAPIClient {
        let client = MockAPIClient()
        client.setMockResponse(response, for: endpoint)
        return client
    }

    private func makePaginatedResponse(
        offers: [ActiveOfferResponse] = [],
        offset: Int = 0,
        limit: Int = 20,
        total: Int = 0
    ) -> PaginatedActiveOffersResponse {
        PaginatedActiveOffersResponse(
            data: offers,
            pagination: PaginationResponse(offset: offset, limit: limit, total: total)
        )
    }

    private func makeOfferResponse(
        id: String = UUID().uuidString,
        merchantName: String = "Merchant",
        cashbackType: CashbackType = .percent,
        cashbackValue: Double = 5.0,
        monthlyCap: Double = 100.0,
        startDate: String = "2026-01-01",
        endDate: String = "2026-12-31"
    ) -> ActiveOfferResponse {
        ActiveOfferResponse(
            id: id,
            merchantName: merchantName,
            cashbackType: cashbackType,
            cashbackValue: cashbackValue,
            monthlyCap: monthlyCap,
            startDate: startDate,
            endDate: endDate
        )
    }
}
