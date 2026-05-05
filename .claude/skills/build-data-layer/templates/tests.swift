// MARK: - Use Case Tests
// File: ClickNBackTests/Unit/Data/<Feature>/Fetch<Model>UseCaseTests.swift

import ClickNBack
import Testing

@MainActor
@Suite("Fetch<Model>UseCase")
struct Fetch<Model>UseCaseTests {

    // Happy path — use the shared mock's default .success(.mock) response
    @Test
    func execute_returns<Feature>sPage_onSuccess() async {
        // Arrange
        let sut = makeSUT()

        // Act
        let result = await sut.execute(offset: 0, limit: 10)

        // Assert
        #expect(result == .success(.mock))
    }

    // Delegation — always verify the use case calls the repository exactly once
    @Test
    func execute_delegatesToRepository() async {
        // Arrange
        let repository = Mock<Feature>Repository()
        let sut = makeSUT(<feature>Repository: repository)

        // Act
        _ = await sut.execute(offset: 0, limit: 10)

        // Assert
        #expect(repository.fetch<Models>CallCount == 1)
    }

    // One test per error case — add a test for every case in Fetch<Model>Error
    @Test
    func execute_returnsUnauthorizedError_onUnauthorizedError() async {
        // Arrange
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .failure(.unauthorized) }
        let sut = makeSUT(<feature>Repository: repository)

        // Act
        let result = await sut.execute(offset: 0, limit: 10)

        // Assert
        #expect(result == .failure(.unauthorized))
    }

    @Test
    func execute_returnsServerError_onServerError() async {
        // Arrange
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .failure(.serverError) }
        let sut = makeSUT(<feature>Repository: repository)

        // Act
        let result = await sut.execute(offset: 0, limit: 10)

        // Assert
        #expect(result == .failure(.serverError))
    }

    @Test
    func execute_returnsNoConnectivityError_onNoConnectivityError() async {
        // Arrange
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .failure(.noConnectivity) }
        let sut = makeSUT(<feature>Repository: repository)

        // Act
        let result = await sut.execute(offset: 0, limit: 10)

        // Assert
        #expect(result == .failure(.noConnectivity))
    }

    @Test
    func execute_returnsRequestTimeoutError_onRequestTimeoutError() async {
        // Arrange
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .failure(.requestTimeout) }
        let sut = makeSUT(<feature>Repository: repository)

        // Act
        let result = await sut.execute(offset: 0, limit: 10)

        // Assert
        #expect(result == .failure(.requestTimeout))
    }

    @Test
    func execute_returnsUnexpectedError_onUnexpectedError() async {
        // Arrange
        let repository = Mock<Feature>Repository()
        repository.fetch<Models>Handler = { _, _ in .failure(.unexpectedError) }
        let sut = makeSUT(<feature>Repository: repository)

        // Act
        let result = await sut.execute(offset: 0, limit: 10)

        // Assert
        #expect(result == .failure(.unexpectedError))
    }

    // MARK: - Helpers

    private func makeSUT(
        <feature>Repository: <Feature>Repository = Mock<Feature>Repository()
    ) -> Fetch<Model>UseCase {
        Fetch<Model>UseCase(<feature>Repository: <feature>Repository)
    }
}
