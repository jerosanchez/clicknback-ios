// MARK: - ViewModel
// File: ClickNBack/Features/<Feature>/<Screen>ViewModel.swift

@Observable final class <Screen>ViewModel {
    enum State { case idle, loading, success(<Data>), error(<Feature>Error) }

    private(set) var state: State = .idle
    private let useCase: <Action>UseCase
    private let analyticsTracker: AnalyticsTracker

    init(useCase: <Action>UseCase, analyticsTracker: AnalyticsTracker) {
        self.useCase = useCase
        self.analyticsTracker = analyticsTracker
    }

    func onAppear() {
        analyticsTracker.track(<Feature>AnalyticsEvent.<screen>Showed)
    }

    func <action>Tapped() async {
        state = .loading
        switch await useCase.execute(...) {
        case .success(let data): state = .success(data)
        case .failure(let error): state = .error(error)
        }
    }
}

// MARK: - Screen
// File: ClickNBack/Features/<Feature>/<Screen>Screen.swift

struct <Screen>Screen: View {
    @State var viewModel: <Screen>ViewModel

    var body: some View {
        // Use AppColors, AppSpacing, AppTypography — never hardcode
        VStack(spacing: AppSpacing.medium) {
            switch viewModel.state {
            case .idle: EmptyView()
            case .loading: ProgressView()
            case .success(let data): contentView(data)
            case .error(let error): errorView(error)
            }
        }
        .onAppear { viewModel.onAppear() }
    }
}

// MARK: - Analytics Events
// File: ClickNBack/Features/<Feature>/<Feature>AnalyticsEvent.swift

enum <Feature>AnalyticsEvent: AnalyticsEvent {
    case <screen>Showed
    case <action>Tapped

    var name: String {
        switch self {
        case .<screen>Showed: return "<feature>_<screen>_showed"
        case .<action>Tapped: return "<feature>_<action>_tapped"
        }
    }

    var parameters: [String: Any] { [:] }
}

// MARK: - Localization Keys
// File: ClickNBack/Features/<Feature>/L10nKey+<feature>.swift

extension L10nKey {
    enum <Feature> {
        static let title = L10nKey("<feature>.title")
        static let errorMessage = L10nKey("<feature>.error_message")
    }
}
