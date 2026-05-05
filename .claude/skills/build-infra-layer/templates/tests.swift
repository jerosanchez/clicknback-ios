// MARK: - API Request Tests
// File: ClickNBackTests/Unit/Infra/Repositories/<Feature>/<Feature>APIRequestTests.swift
//
// Test every property of every enum case.
// - method: correct HTTP verb
// - endpoint: exact path string
// - headers: nil (or expected value)
// - queryParams: correct key/value pairs AND correct count
// - body: nil for GET; correct keys for POST/PUT

import ClickNBack
import Testing

@MainActor
@Suite("<Feature>APIRequest")
struct <Feature>APIRequestTests {

    // MARK: - method

    @Test
    func method_returnsGet_forList<Models>Case() {
        let sut = <Feature>APIRequest.list<Models>(offset: 0, limit: 10)
        #expect(sut.method == .GET)
    }

    // MARK: - endpoint

    @Test
    func endpoint_returns<Resource>Path_forList<Models>Case() {
        let sut = <Feature>APIRequest.list<Models>(offset: 0, limit: 10)
        #expect(sut.endpoint == "v1/<resource>")
    }

    // MARK: - headers

    @Test
    func headers_returnsNil_forList<Models>Case() {
        let sut = <Feature>APIRequest.list<Models>(offset: 0, limit: 10)
        #expect(sut.headers == nil)
    }

    // MARK: - queryParams

    @Test
    func queryParams_containsOffsetAndLimit_forList<Models>Case() {
        let sut = <Feature>APIRequest.list<Models>(offset: 20, limit: 10)
        #expect(sut.queryParams?["offset"] == "20")
        #expect(sut.queryParams?["limit"] == "10")
    }

    @Test
    func queryParams_containsOnlyOffsetAndLimit_forList<Models>Case() {
        // Guards against accidental extra query params
        let sut = <Feature>APIRequest.list<Models>(offset: 0, limit: 10)
        #expect(sut.queryParams?.count == 2)
    }

    @Test
    func queryParams_mapsOffsetZero_forList<Models>Case() {
        let sut = <Feature>APIRequest.list<Models>(offset: 0, limit: 10)
        #expect(sut.queryParams?["offset"] == "0")
    }

    @Test
    func queryParams_mapsLargeOffset_forList<Models>Case() {
        let sut = <Feature>APIRequest.list<Models>(offset: 500, limit: 10)
        #expect(sut.queryParams?["offset"] == "500")
    }

    // MARK: - body

    @Test
    func body_returnsNil_forList<Models>Case() {
        let sut = <Feature>APIRequest.list<Models>(offset: 0, limit: 10)
        #expect(sut.body == nil)
    }
}

// MARK: - Remote Repository Tests
// File: ClickNBackTests/Unit/Infra/Repositories/<Feature>/Remote<Feature>RepositoryFetch<Models>Tests.swift
//
// All factory helpers are private instance methods inside the @Suite struct —
// NOT free functions at module scope. Required for Swift 6 actor isolation.

import Foundation
import ClickNBack
import Testing

@MainActor
@Suite("Remote<Feature>Repository.fetch<Models>")
struct Remote<Feature>RepositoryFetch<Models>Tests {

    // MARK: - Success

    @Test
    func fetch<Models>_returns<Feature>sPage_onSuccessfulResponse() async {
        // Arrange
        let itemId = UUID().uuidString
        let response = makePaginatedResponse(
            items: [makeItemResponse(id: itemId, merchantName: "Amazon")],
            offset: 0,
            limit: 10,
            total: 1
        )
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(response, for: "v1/<resource>")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetch<Models>(offset: 0, limit: 10)

        // Assert
        guard case .success(let page) = result else {
            #expect(Bool(false), "Expected success")
            return
        }
        #expect(page.<models>.count == 1)
        #expect(page.<models>[0].id == itemId)
        #expect(page.pagination.offset == 0)
        #expect(page.pagination.limit == 10)
        #expect(page.pagination.total == 1)
    }

    @Test
    func fetch<Models>_mapsAllFields_onSuccessfulResponse() async {
        // Arrange — supply every field explicitly to catch mapping gaps
        let itemId = UUID().uuidString
        let response = makePaginatedResponse(items: [makeItemResponse(
            id: itemId,
            merchantName: "Starbucks",
            amount: "8.50",
            status: "pending",
            cashbackAmount: "0.85",
            cashbackStatus: "pending",
            createdAt: "2026-01-01T12:00:00Z"
        )])
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(response, for: "v1/<resource>")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetch<Models>(offset: 0, limit: 10)

        // Assert
        guard case .success(let page) = result else {
            #expect(Bool(false), "Expected success")
            return
        }
        let item = page.<models>[0]
        #expect(item.id == itemId)
        #expect(item.merchantName == "Starbucks")
        #expect(item.amount == Decimal(string: "8.50"))
        #expect(item.status == .pending)
        #expect(item.cashbackAmount == Decimal(string: "0.85"))
        #expect(item.cashbackStatus == "pending")
        // Use the Unix timestamp for the expected date — compute offline:
        //   python3 -c "from datetime import datetime,timezone; print(int(datetime(2026,1,1,12,0,0,tzinfo=timezone.utc).timestamp()))"
        #expect(item.createdAt == Date(timeIntervalSince1970: 1_767_268_800))
    }

    @Test
    func fetch<Models>_mapsNilCashbackStatus_whenResponseHasNullCashbackStatus() async {
        // Arrange
        let response = makePaginatedResponse(items: [makeItemResponse(cashbackStatus: nil)])
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(response, for: "v1/<resource>")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetch<Models>(offset: 0, limit: 10)

        // Assert
        guard case .success(let page) = result else {
            #expect(Bool(false), "Expected success")
            return
        }
        #expect(page.<models>[0].cashbackStatus == nil)
    }

    @Test
    func fetch<Models>_mapsAllStatuses() async {
        // Arrange — one item per status value; verifies the mapper handles every raw string
        let items = [
            makeItemResponse(id: UUID().uuidString, status: "pending"),
            makeItemResponse(id: UUID().uuidString, status: "confirmed"),
            makeItemResponse(id: UUID().uuidString, status: "reversed"),
            makeItemResponse(id: UUID().uuidString, status: "rejected")
        ]
        let response = makePaginatedResponse(items: items, total: 4)
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(response, for: "v1/<resource>")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetch<Models>(offset: 0, limit: 10)

        // Assert
        guard case .success(let page) = result else {
            #expect(Bool(false), "Expected success")
            return
        }
        #expect(page.<models>[0].status == .pending)
        #expect(page.<models>[1].status == .confirmed)
        #expect(page.<models>[2].status == .reversed)
        #expect(page.<models>[3].status == .rejected)
    }

    @Test
    func fetch<Models>_mapsAll<Models>_whenResponseContainsMultipleItems() async {
        // Arrange — multiple items catch bugs that only affect the first or last element
        let id1 = UUID().uuidString
        let id2 = UUID().uuidString
        let id3 = UUID().uuidString
        let items = [
            makeItemResponse(id: id1, merchantName: "Amazon"),
            makeItemResponse(id: id2, merchantName: "Starbucks"),
            makeItemResponse(id: id3, merchantName: "Apple Store")
        ]
        let response = makePaginatedResponse(items: items, total: 3)
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(response, for: "v1/<resource>")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        let result = await sut.fetch<Models>(offset: 0, limit: 10)

        // Assert
        guard case .success(let page) = result else {
            #expect(Bool(false), "Expected success")
            return
        }
        #expect(page.<models>.count == 3)
        #expect(page.<models>[0].id == id1)
        #expect(page.<models>[1].id == id2)
        #expect(page.<models>[2].id == id3)
    }

    @Test
    func fetch<Models>_callsCorrectEndpoint_onRequest() async {
        // Arrange
        let apiClient = MockAPIClient()
        apiClient.setMockResponse(makePaginatedResponse(), for: "v1/<resource>")
        let sut = makeSUT(apiClient: apiClient)

        // Act
        _ = await sut.fetch<Models>(offset: 20, limit: 10)

        // Assert
        #expect(apiClient.requestHistory.count == 1)
        #expect(apiClient.requestHistory[0].endpoint == "v1/<resource>")
    }

    // MARK: - Error mapping

    @Test
    func fetch<Models>_returnsUnauthorized_on401APIError() async {
        let apiClient = MockAPIClient()
        apiClient.setMockError(.apiError(401, nil))
        let sut = makeSUT(apiClient: apiClient)
        let result = await sut.fetch<Models>(offset: 0, limit: 10)
        guard case .failure(.unauthorized) = result else {
            #expect(Bool(false), "Expected unauthorized error"); return
        }
    }

    @Test
    func fetch<Models>_returnsUnexpectedError_onNon401APIError() async {
        let apiClient = MockAPIClient()
        apiClient.setMockError(.apiError(422, nil))
        let sut = makeSUT(apiClient: apiClient)
        let result = await sut.fetch<Models>(offset: 0, limit: 10)
        guard case .failure(.unexpectedError) = result else {
            #expect(Bool(false), "Expected unexpectedError"); return
        }
    }

    @Test
    func fetch<Models>_returnsServerError_onServerError() async {
        let apiClient = MockAPIClient()
        apiClient.setMockError(.serverError(500))
        let sut = makeSUT(apiClient: apiClient)
        let result = await sut.fetch<Models>(offset: 0, limit: 10)
        guard case .failure(.serverError) = result else {
            #expect(Bool(false), "Expected serverError"); return
        }
    }

    @Test
    func fetch<Models>_returnsRequestTimeout_onRequestTimeoutError() async {
        let apiClient = MockAPIClient()
        apiClient.setMockError(.requestTimeout)
        let sut = makeSUT(apiClient: apiClient)
        let result = await sut.fetch<Models>(offset: 0, limit: 10)
        guard case .failure(.requestTimeout) = result else {
            #expect(Bool(false), "Expected requestTimeout error"); return
        }
    }

    @Test
    func fetch<Models>_returnsNoConnectivity_onNoConnectionError() async {
        let apiClient = MockAPIClient()
        apiClient.setMockError(.noConnection)
        let sut = makeSUT(apiClient: apiClient)
        let result = await sut.fetch<Models>(offset: 0, limit: 10)
        guard case .failure(.noConnectivity) = result else {
            #expect(Bool(false), "Expected noConnectivity error"); return
        }
    }

    // MARK: - Helpers
    //
    // IMPORTANT: All factories are private instance methods inside the @Suite struct.
    // Never move them to free functions at module scope — that breaks Swift 6 actor isolation.

    private func makeSUT(apiClient: APIClient? = nil) -> Remote<Feature>Repository {
        Remote<Feature>Repository(apiClient: apiClient ?? makeAPIClient())
    }

    private func makeAPIClient(
        response: Paginated<Model>sResponse = Paginated<Model>sResponse(
            data: [],
            pagination: PaginationResponse(offset: 0, limit: 10, total: 0)
        ),
        endpoint: String = "v1/<resource>"
    ) -> MockAPIClient {
        let client = MockAPIClient()
        client.setMockResponse(response, for: endpoint)
        return client
    }

    private func makeItemResponse(
        id: String = UUID().uuidString,
        merchantName: String = "Test Merchant",
        amount: String = "10.00",
        status: String = "confirmed",
        cashbackAmount: String = "1.00",
        cashbackStatus: String? = "confirmed",
        createdAt: String = "2026-01-01T12:00:00Z"
    ) -> <Model>Response {
        <Model>Response(
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
        items: [<Model>Response] = [],
        offset: Int = 0,
        limit: Int = 10,
        total: Int = 0
    ) -> Paginated<Model>sResponse {
        Paginated<Model>sResponse(
            data: items,
            pagination: PaginationResponse(offset: offset, limit: limit, total: total)
        )
    }
}
