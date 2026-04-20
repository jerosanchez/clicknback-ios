// MARK: - Container
// File: ClickNBack/Main/Composition/<Screen>Container.swift

struct <Screen>Container: View {
    @Environment(CompositionRoot.self) private var root

    var body: some View {
        <Screen>Screen(viewModel: makeViewModel())
    }

    private func makeViewModel() -> <Screen>ViewModel {
        <Screen>ViewModel(
            useCase: make<Action>UseCase(),
            analyticsTracker: root.analyticsTracker
        )
    }

    private func make<Action>UseCase() -> <Action>UseCase {
        <Action>UseCase(repository: Remote<Feature>Repository(apiClient: root.apiClient))
    }
}

// MARK: - CompositionRoot Integration Note
//
// If <Screen>Container is a top-level destination, register it in AppState
// or the navigation flow in ClickNBackApp.swift.
//
// The container reads all dependencies from @Environment(CompositionRoot.self)
// — never pass them directly through the view hierarchy.
//
// If the feature needs new infrastructure services (e.g. a new storage key
// or a new API client scope), add a computed var to CompositionRoot:
//
//   var <feature>Repository: <Feature>Repository {
//       Remote<Feature>Repository(apiClient: apiClient)
//   }

// MARK: - Public Mock
// File: ClickNBack/Support/Mocks/Mock<Feature>Repository.swift

public final class Mock<Feature>Repository: <Feature>Repository {
    public typealias <Action>Handler = (...) async -> Result<<Model>, <Feature>Error>
    public var <action>Handler: <Action>Handler?
    public init() {}

    public func <action>(...) async -> Result<<Model>, <Feature>Error> {
        await <action>Handler?(...) ?? .success(.mock)
    }
}
