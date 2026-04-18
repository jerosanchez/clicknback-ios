//

@testable import ClickNBack
import Testing

@MainActor
@Suite("SignInViewModel")
struct SignInViewModelTests {

    // MARK: - onAppear

    @Test
    func onAppear_tracksLoginScreenShowed() async {
        // Arrange
        let tracker = MockAnalyticsTracker()
        let sut = makeSUT(analyticsTracker: tracker)

        // Act
        sut.onAppear()
        await Task.yield()

        // Assert
        #expect(tracker.trackedEventNames == [SignInAnalyticsEvents.loginScreenShowed.name])
    }

    // MARK: - signInTapped – state transitions

    @Test
    func signInTapped_setsSuccessState_onValidCredentials() async {
        // Arrange
        let sut = makeSUT()
        sut.email = "user@example.com"
        sut.password = "secret"

        // Act
        await sut.signInTapped()

        // Assert
        #expect(sut.state == .success)
    }

    @Test
    func signInTapped_setsErrorBadCredentials_onBadCredentials() async {
        // Arrange
        let repository = MockAuthRepository()
        repository.loginHandler = { _ in .failure(.badCredentials) }
        let sut = makeSUT(authRepository: repository)

        // Act
        await sut.signInTapped()

        // Assert
        #expect(sut.state == .error(.badCredentials))
    }

    @Test
    func signInTapped_setsErrorServerError_onServerError() async {
        // Arrange
        let repository = MockAuthRepository()
        repository.loginHandler = { _ in .failure(.serverError) }
        let sut = makeSUT(authRepository: repository)

        // Act
        await sut.signInTapped()

        // Assert
        #expect(sut.state == .error(.serverError))
    }

    @Test
    func signInTapped_setsErrorTimeout_onRequestTimeout() async {
        // Arrange
        let repository = MockAuthRepository()
        repository.loginHandler = { _ in .failure(.requestTimeout) }
        let sut = makeSUT(authRepository: repository)

        // Act
        await sut.signInTapped()

        // Assert
        #expect(sut.state == .error(.timeout))
    }

    @Test
    func signInTapped_setsErrorNoConnectivity_onNoConnectivity() async {
        // Arrange
        let repository = MockAuthRepository()
        repository.loginHandler = { _ in .failure(.noConnectivity) }
        let sut = makeSUT(authRepository: repository)

        // Act
        await sut.signInTapped()

        // Assert
        #expect(sut.state == .error(.noConnectivity))
    }

    @Test
    func signInTapped_setsErrorServerError_onUnexpectedError() async {
        // Arrange
        let repository = MockAuthRepository()
        repository.loginHandler = { _ in .failure(.unexpectedError(nil)) }
        let sut = makeSUT(authRepository: repository)

        // Act
        await sut.signInTapped()

        // Assert
        #expect(sut.state == .error(.serverError))
    }

    // MARK: - signInTapped – isLoading convenience property

    @Test
    func isLoading_returnsFalse_initially() {
        // Arrange
        let sut = makeSUT()

        // Assert
        #expect(sut.isLoading == false)
    }

    @Test
    func isLoading_returnsFalse_afterSignInCompletes() async {
        // Arrange
        let sut = makeSUT()

        // Act
        await sut.signInTapped()

        // Assert
        #expect(sut.isLoading == false)
    }

    // MARK: - signInTapped – analytics

    @Test
    func signInTapped_tracksLoginSucceeded_onSuccess() async {
        // Arrange
        let tracker = MockAnalyticsTracker()
        let sut = makeSUT(analyticsTracker: tracker)
        sut.email = "user@example.com"
        sut.password = "secret"

        // Act
        await sut.signInTapped()
        await Task.yield()

        // Assert
        let expectedEventName = SignInAnalyticsEvents.loginSucceeded(email: sut.email).name
        #expect(tracker.trackedEventNames.contains(expectedEventName))
    }

    @Test
    func signInTapped_doesNotTrackLoginSucceeded_onBadCredentials() async {
        // Arrange
        let tracker = MockAnalyticsTracker()
        let repository = MockAuthRepository()
        repository.loginHandler = { _ in .failure(.badCredentials) }
        let sut = makeSUT(authRepository: repository, analyticsTracker: tracker)

        // Act
        await sut.signInTapped()
        await Task.yield()

        // Assert
        let loginSucceededName = SignInAnalyticsEvents.loginSucceeded(email: "any").name
        #expect(!tracker.trackedEventNames.contains(loginSucceededName))
    }
}

// MARK: - Helpers

extension SignInViewModelTests {
    private func makeSUT(
        authRepository: AuthRepository = MockAuthRepository(),
        tokenStorage: KeyValueStorage = MockKeyValueStorage(),
        analyticsTracker: AnalyticsTracker = MockAnalyticsTracker()
    ) -> SignInViewModel {
        let loginUseCase = LoginUseCase(
            authRepository: authRepository,
            tokenStorage: tokenStorage
        )
        return SignInViewModel(
            loginUseCase: loginUseCase,
            analyticsTracker: analyticsTracker
        )
    }
}

extension SignInViewModel.State: @retroactive Equatable {
    public nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.success, .success):
            return true
        case (.error(let l), .error(let r)):
            return l == r
        default:
            return false
        }
    }
}

extension SignInViewModel.Error {
    public nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.badCredentials, .badCredentials),
             (.serverError, .serverError),
             (.timeout, .timeout),
             (.noConnectivity, .noConnectivity):
            return true
        default:
            return false
        }
    }
}
