import Foundation
import ClickNBack
import Testing

@MainActor
@Suite("RemotePurchasesRepository.fetchUserPurchases")
struct RemotePurchasesRepositoryFetchUserPurchasesTests {

    // MARK: - Success

    @Test
    func fetchUserPurchases_returnsPurchasesPage_onSuccessfulResponse() async {
        // Arrange
        let purchaseId = UUID().uuidString
        let response = makePaginatedResponse(
            purchases: [makePurchaseResponse(id: purchaseId, merchantName: "Amazon")],
            offset: 0,
            limit: 10,
            total: 1
        )
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(response, for: "v1/users/me/purchases")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchUserPurchases(offset: 0, limit: 10)

        // Assert
        guard case .success(let page) = result else {
            #expect(Bool(false), "Expected success")
            return
        }
        #expect(page.purchases.count == 1)
        #expect(page.purchases[0].id == purchaseId)
        #expect(page.purchases[0].merchantName == "Amazon")
        #expect(page.pagination.offset == 0)
        #expect(page.pagination.limit == 10)
        #expect(page.pagination.total == 1)
    }

    @Test
    func fetchUserPurchases_mapsAllPurchaseFields_onSuccessfulResponse() async {
        // Arrange
        let purchaseId = UUID().uuidString
        let purchaseResponse = makePurchaseResponse(
            id: purchaseId,
            merchantName: "Starbucks",
            amount: "8.50",
            status: "pending",
            cashbackAmount: "0.85",
            cashbackStatus: "pending",
            createdAt: "2026-01-01T12:00:00Z"
        )
        let response = makePaginatedResponse(purchases: [purchaseResponse])
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(response, for: "v1/users/me/purchases")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchUserPurchases(offset: 0, limit: 10)

        // Assert
        guard case .success(let page) = result else {
            #expect(Bool(false), "Expected success")
            return
        }
        let purchase = page.purchases[0]
        #expect(purchase.id == purchaseId)
        #expect(purchase.merchantName == "Starbucks")
        #expect(purchase.amount == Decimal(string: "8.50"))
        #expect(purchase.status == .pending)
        #expect(purchase.cashbackAmount == Decimal(string: "0.85"))
        #expect(purchase.cashbackStatus == "pending")
        #expect(purchase.createdAt == Date(timeIntervalSince1970: 1_767_268_800))
    }

    @Test
    func fetchUserPurchases_mapsCashbackStatusNil_whenResponseHasNullCashbackStatus() async {
        // Arrange
        let purchaseResponse = makePurchaseResponse(cashbackStatus: nil)
        let response = makePaginatedResponse(purchases: [purchaseResponse])
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(response, for: "v1/users/me/purchases")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchUserPurchases(offset: 0, limit: 10)

        // Assert
        guard case .success(let page) = result else {
            #expect(Bool(false), "Expected success")
            return
        }
        #expect(page.purchases[0].cashbackStatus == nil)
    }

    @Test
    func fetchUserPurchases_mapsAllStatuses_forEachPurchaseStatus() async {
        // Arrange
        let purchases = [
            makePurchaseResponse(id: UUID().uuidString, status: "pending"),
            makePurchaseResponse(id: UUID().uuidString, status: "confirmed"),
            makePurchaseResponse(id: UUID().uuidString, status: "reversed"),
            makePurchaseResponse(id: UUID().uuidString, status: "rejected")
        ]
        let response = makePaginatedResponse(purchases: purchases, total: 4)
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(response, for: "v1/users/me/purchases")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchUserPurchases(offset: 0, limit: 10)

        // Assert
        guard case .success(let page) = result else {
            #expect(Bool(false), "Expected success")
            return
        }
        #expect(page.purchases[0].status == .pending)
        #expect(page.purchases[1].status == .confirmed)
        #expect(page.purchases[2].status == .reversed)
        #expect(page.purchases[3].status == .rejected)
    }

    @Test
    func fetchUserPurchases_mapsAllPurchases_whenResponseContainsMultiplePurchases() async {
        // Arrange
        let purchaseId1 = UUID().uuidString
        let purchaseId2 = UUID().uuidString
        let purchaseId3 = UUID().uuidString
        let purchases = [
            makePurchaseResponse(id: purchaseId1, merchantName: "Amazon"),
            makePurchaseResponse(id: purchaseId2, merchantName: "Starbucks"),
            makePurchaseResponse(id: purchaseId3, merchantName: "Apple Store")
        ]
        let response = makePaginatedResponse(purchases: purchases, offset: 0, limit: 10, total: 3)
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(response, for: "v1/users/me/purchases")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchUserPurchases(offset: 0, limit: 10)

        // Assert
        guard case .success(let page) = result else {
            #expect(Bool(false), "Expected success")
            return
        }
        #expect(page.purchases.count == 3)
        #expect(page.purchases[0].id == purchaseId1)
        #expect(page.purchases[0].merchantName == "Amazon")
        #expect(page.purchases[1].id == purchaseId2)
        #expect(page.purchases[1].merchantName == "Starbucks")
        #expect(page.purchases[2].id == purchaseId3)
        #expect(page.purchases[2].merchantName == "Apple Store")
    }

    @Test
    func fetchUserPurchases_passesOffsetAndLimitToCorrectEndpoint_onRequest() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(makePaginatedResponse(), for: "v1/users/me/purchases")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        _ = await sut.fetchUserPurchases(offset: 20, limit: 10)

        // Assert
        #expect(apiClient.requestHistory.count == 1)
        #expect(apiClient.requestHistory[0].endpoint == "v1/users/me/purchases")
    }

    // MARK: - Error mapping

    @Test
    func fetchUserPurchases_returnsUnauthorized_on401APIError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.apiError(401, nil))
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchUserPurchases(offset: 0, limit: 10)

        // Assert
        guard case .failure(.unauthorized) = result else {
            #expect(Bool(false), "Expected unauthorized error")
            return
        }
    }

    @Test
    func fetchUserPurchases_returnsUnexpectedError_onNon401APIError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.apiError(422, nil))
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchUserPurchases(offset: 0, limit: 10)

        // Assert
        guard case .failure(.unexpectedError) = result else {
            #expect(Bool(false), "Expected unexpectedError")
            return
        }
    }

    @Test
    func fetchUserPurchases_returnsServerError_onServerError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.serverError(500))
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchUserPurchases(offset: 0, limit: 10)

        // Assert
        guard case .failure(.serverError) = result else {
            #expect(Bool(false), "Expected serverError")
            return
        }
    }

    @Test
    func fetchUserPurchases_returnsRequestTimeout_onRequestTimeoutError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.requestTimeout)
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchUserPurchases(offset: 0, limit: 10)

        // Assert
        guard case .failure(.requestTimeout) = result else {
            #expect(Bool(false), "Expected requestTimeout error")
            return
        }
    }

    @Test
    func fetchUserPurchases_returnsNoConnectivity_onNoConnectionError() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockError(.noConnection)
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetchUserPurchases(offset: 0, limit: 10)

        // Assert
        guard case .failure(.noConnectivity) = result else {
            #expect(Bool(false), "Expected noConnectivity error")
            return
        }
    }

    // MARK: - Helpers

    private func makeSUT(apiClient: APIClient? = nil) -> RemotePurchasesRepository {
        RemotePurchasesRepository(apiClient: apiClient ?? makeAPIClient())
    }

    private func makeAPIClient(
        response: PaginatedUserPurchasesResponse = PaginatedUserPurchasesResponse(
            data: [],
            pagination: PaginationResponse(offset: 0, limit: 10, total: 0)
        ),
        endpoint: String = "v1/users/me/purchases"
    ) -> MockAPIClient {
        let client = MockAPIClient()
        client.setMockResponse(response, for: endpoint)
        return client
    }

    private func makePurchaseResponse(
        id: String = UUID().uuidString,
        merchantName: String = "Test Merchant",
        amount: String = "25.99",
        status: String = "confirmed",
        cashbackAmount: String = "2.60",
        cashbackStatus: String? = "confirmed",
        createdAt: String = "2026-01-01T12:00:00Z"
    ) -> UserPurchaseResponse {
        UserPurchaseResponse(
            id: id,
            merchantName: merchantName,
            amount: amount,
            status: status,
            cashbackAmount: cashbackAmount,
            cashbackStatus: cashbackStatus,
            createdAt: createdAt
        )
    }

    private func makePaginatedResponse(
        purchases: [UserPurchaseResponse] = [],
        offset: Int = 0,
        limit: Int = 10,
        total: Int = 0
    ) -> PaginatedUserPurchasesResponse {
        PaginatedUserPurchasesResponse(
            data: purchases,
            pagination: PaginationResponse(offset: offset, limit: limit, total: total)
        )
    }
}
