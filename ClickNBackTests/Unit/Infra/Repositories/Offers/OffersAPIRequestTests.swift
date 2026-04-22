import ClickNBack
import Testing

@MainActor
@Suite("OffersAPIRequest")
struct OffersAPIRequestTests {

    // MARK: - method

    @Test
    func method_returnsGet_forListActiveCase() {
        // Arrange
        let sut = OffersAPIRequest.listActive(offset: 0, limit: 20)

        // Assert
        #expect(sut.method == .GET)
    }

    // MARK: - endpoint

    @Test
    func endpoint_returnsOffersActivePath_forListActiveCase() {
        // Arrange
        let sut = OffersAPIRequest.listActive(offset: 0, limit: 20)

        // Assert
        #expect(sut.endpoint == "v1/offers/active")
    }

    // MARK: - headers

    @Test
    func headers_returnsNil_forListActiveCase() {
        // Arrange
        let sut = OffersAPIRequest.listActive(offset: 0, limit: 20)

        // Assert
        #expect(sut.headers == nil)
    }

    // MARK: - queryParams

    @Test
    func queryParams_containsOffsetAndLimit_forListActiveCase() {
        // Arrange
        let sut = OffersAPIRequest.listActive(offset: 10, limit: 50)

        // Assert
        #expect(sut.queryParams?["offset"] == "10")
        #expect(sut.queryParams?["limit"] == "50")
    }

    @Test
    func queryParams_containsOnlyOffsetAndLimit_forListActiveCase() {
        // Arrange
        let sut = OffersAPIRequest.listActive(offset: 0, limit: 20)

        // Assert
        #expect(sut.queryParams?.count == 2)
    }

    @Test
    func queryParams_mapsOffsetZero_forListActiveCase() {
        // Arrange
        let sut = OffersAPIRequest.listActive(offset: 0, limit: 20)

        // Assert
        #expect(sut.queryParams?["offset"] == "0")
    }

    @Test
    func queryParams_mapsLargeOffset_forListActiveCase() {
        // Arrange
        let sut = OffersAPIRequest.listActive(offset: 1000, limit: 20)

        // Assert
        #expect(sut.queryParams?["offset"] == "1000")
    }

    // MARK: - body

    @Test
    func body_returnsNil_forListActiveCase() {
        // Arrange
        let sut = OffersAPIRequest.listActive(offset: 0, limit: 20)

        // Assert
        #expect(sut.body == nil)
    }
}
