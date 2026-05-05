import ClickNBack
import Testing

@MainActor
@Suite("PurchasesAPIRequest")
struct PurchasesAPIRequestTests {

    // MARK: - method

    @Test
    func method_returnsGet_forListUserPurchasesCase() {
        // Arrange
        let sut = PurchasesAPIRequest.listUserPurchases(offset: 0, limit: 10)

        // Assert
        #expect(sut.method == .GET)
    }

    // MARK: - endpoint

    @Test
    func endpoint_returnsUsersPurchasesPath_forListUserPurchasesCase() {
        // Arrange
        let sut = PurchasesAPIRequest.listUserPurchases(offset: 0, limit: 10)

        // Assert
        #expect(sut.endpoint == "v1/users/me/purchases")
    }

    // MARK: - headers

    @Test
    func headers_returnsNil_forListUserPurchasesCase() {
        // Arrange
        let sut = PurchasesAPIRequest.listUserPurchases(offset: 0, limit: 10)

        // Assert
        #expect(sut.headers == nil)
    }

    // MARK: - queryParams

    @Test
    func queryParams_containsOffsetAndLimit_forListUserPurchasesCase() {
        // Arrange
        let sut = PurchasesAPIRequest.listUserPurchases(offset: 20, limit: 10)

        // Assert
        #expect(sut.queryParams?["offset"] == "20")
        #expect(sut.queryParams?["limit"] == "10")
    }

    @Test
    func queryParams_containsOnlyOffsetAndLimit_forListUserPurchasesCase() {
        // Arrange
        let sut = PurchasesAPIRequest.listUserPurchases(offset: 0, limit: 10)

        // Assert
        #expect(sut.queryParams?.count == 2)
    }

    @Test
    func queryParams_mapsOffsetZero_forListUserPurchasesCase() {
        // Arrange
        let sut = PurchasesAPIRequest.listUserPurchases(offset: 0, limit: 10)

        // Assert
        #expect(sut.queryParams?["offset"] == "0")
    }

    @Test
    func queryParams_mapsLargeOffset_forListUserPurchasesCase() {
        // Arrange
        let sut = PurchasesAPIRequest.listUserPurchases(offset: 500, limit: 10)

        // Assert
        #expect(sut.queryParams?["offset"] == "500")
    }

    // MARK: - body

    @Test
    func body_returnsNil_forListUserPurchasesCase() {
        // Arrange
        let sut = PurchasesAPIRequest.listUserPurchases(offset: 0, limit: 10)

        // Assert
        #expect(sut.body == nil)
    }
}
