---
name: build-ui-layer
description: Scaffold the UI layer (ViewModel, Screen, subviews, analytics, localization, composition wiring, preview helpers, and unit tests) for a new feature. Use after the data and infrastructure layers are in place.
argument-hint: "[Feature name and description, or link to issue]"
---

Scaffold the UI layer for: $ARGUMENTS

## What This Skill Produces

All files for `ClickNBack/Features/<Feature>/`, `ClickNBack/Main/Composition/`, and `ClickNBack/Support/Preview/Container/`, plus corresponding tests. The exact set of files depends on the feature — a paginated list screen produces a ViewModel with `loadMore` and `refresh`; a form screen produces a ViewModel with input bindings and a submit action. Read the spec and check how the Offers feature is built before writing any code.

---

## Step 1 — Feature Files (`ClickNBack/Features/<Feature>/`)

See `templates/viewmodel.swift`, `templates/screen.swift` for full boilerplate.

### ViewModel

- `@Observable final class` — never `ObservableObject`
- Standard state enum:
  ```swift
  enum State {
      case loading                              // initial load, no data yet
      case loaded([<Model>], hasMore: Bool)     // data visible, idle
      case loadingMore([<Model>])               // paginating
      case refreshing([<Model>])                // pull-to-refresh
      case empty                                // zero items returned
      case error(<Fetch>Error)                  // network failed
  }
  ```
- **Derived state computed properties** (`visibleItems`, `isLoadingMore`, `hasMore`) — the Screen uses these to avoid a `switch` that would destroy and recreate `ScrollView`, breaking scroll position
- All dependencies injected via constructor — never created inside the ViewModel; never use singletons or service locators
- `onAppear()` is idempotent: guarded with a `hasAppeared` flag so it fires only once
- `loadMore()` guards with `guard case .loaded(_, hasMore: true) = state` — never fire during loading or when exhausted
- `refresh()` sets the transitional state (`.refreshing` or `.loading`) before the async call; on error restores the previous data if visible
- Analytics tracked with a private `track(_ event:)` helper that wraps the call in `Task { }` — keeps the public API synchronous
- Never call `@MainActor`-isolated code from a `nonisolated` context — all ViewModel methods are implicitly `@MainActor` (project-wide isolation)

### Screen

- `@State var viewModel: <Feature>ViewModel` — `@State` not `@StateObject`; ViewModel is `@Observable`
- Single `if let visible = viewModel.visibleItems` branch **before** the `switch` — prevents SwiftUI from rebuilding the `ScrollView` when transitioning `.loaded → .loadingMore → .loaded`, which would reset scroll position
- Infinite scroll trigger: `Color.clear.frame(height: 1).onAppear { Task { await viewModel.loadMore() } }` inside `LazyVStack`, rendered only when `hasMore == true` and `isLoadingMore == false`
- Skeleton is a separate `<Feature>SkeletonView` — shown only while `state == .loading`; mirrors the real card/row layout using `RoundedRectangle` fills + `ShimmerModifier`
- Empty and error states wrapped in `ScrollView { … }.refreshable { }` — users can pull-to-refresh even from these states
- `ErrorStateView` requires the error type to conform to `ErrorStateViewErrorType` — add `<Fetch>Error+ErrorStateView.swift` in `ClickNBack/Data/<Feature>/`
- Always use **named `#Preview` blocks** (`#Preview("Success")`, `#Preview("Empty")`, `#Preview("No Connectivity")`) via `PreviewContainer`; never instantiate a ViewModel inside `#Preview`; a single unnamed preview is not acceptable
- All user-facing strings from the `.xcstrings` catalog via `L10nKey+<feature>.swift`; all colors, spacing, fonts, and icons from the design system tokens — never hardcoded

### Analytics Event Enum

```swift
// File: ClickNBack/Features/<Feature>/<Feature>AnalyticsEvent.swift
enum <Feature>AnalyticsEvent: AnalyticsEvent {
    case screenShowed
    // add one case per tracked interaction (tap, submit, error-displayed, etc.)

    var name: String { ... }        // kebab-case: "feature-screen-showed"
    var properties: [String: Any] { ... }
}
```

### Localization

- `L10nKey+<feature>.swift` — nested enums per UI section; keys follow `<feature>.<section>.<element>` pattern
- `<Feature>.xcstrings` — one entry per key; always include English and Spanish localizations; `extractionState: "manual"`
- Never hardcode user-facing strings — not even in previews

### ErrorStateViewErrorType Conformance

When the feature error type is used with `ErrorStateView`, add:

```swift
// File: ClickNBack/Data/<Feature>/<Fetch>Error+ErrorStateView.swift
extension <Fetch>Error: ErrorStateViewErrorType {
    public var errorStateIconName: String {
        switch self {
        case .unauthorized:   AppIcons.ErrorState.unauthorized
        case .serverError:    AppIcons.ErrorState.serverError
        case .requestTimeout: AppIcons.ErrorState.requestTimeout
        case .noConnectivity: AppIcons.ErrorState.noConnectivity
        case .unexpectedError: AppIcons.ErrorState.unexpectedError
        }
    }
}
```

---

## Step 2 — Composition (`ClickNBack/Main/Composition/`)

See `templates/composition.swift` for full boilerplate.

```swift
// File: ClickNBack/Main/Composition/<Screen>Container.swift
struct <Screen>Container: View {
    var body: some View {
        <Screen>Screen(
            viewModel: <Screen>ViewModel(
                fetch<Models>UseCase: Fetch<Model>UseCase(
                    <feature>Repository: CompositionRoot.<feature>Repository
                ),
                analyticsTracker: CompositionRoot.analyticsTracker
            )
        )
    }
}
```

Rules:
- `Composition/` is for wiring **only** — `CompositionRoot.swift` + `<Screen>Container.swift` files; never put startup tasks here
- Every screen with a ViewModel gets its own `<Screen>Container` — the container is the **only** place `CompositionRoot` properties are read and injected
- Never instantiate a ViewModel inside a `View` body or `#Preview` block
- If the feature requires a `<feature>Repository` that doesn't exist yet, add it to `CompositionRoot.swift`

---

## Step 3 — Preview Helpers (`ClickNBack/Support/Preview/Container/`)

```swift
// File: ClickNBack/Support/Preview/Container/PreviewContainer+<feature>.swift
extension PreviewContainer {
    // Base factory — flexible handler for custom and test-driven scenarios
    static func <feature>Screen(
        fetch<Model>Handler: Fetch<Model>Handler? = nil,
        appLanguage: AppLanguage = .english
    ) -> some View {
        let repository = Mock<Feature>Repository()
        repository.fetch<Model>Handler = fetch<Model>Handler
        return <Feature>Screen(
            viewModel: <Feature>ViewModel(
                fetch<Models>UseCase: Fetch<Model>UseCase(
                    <feature>Repository: repository
                ),
                analyticsTracker: MockAnalyticsTracker()
            )
        )
        .environment(\.locale, appLanguage.locale)
    }

    // State-specific convenience factories — used by named #Preview blocks
    static func <feature>ScreenEmpty(
        appLanguage: AppLanguage = .english
    ) -> some View {
        <feature>Screen(
            fetch<Model>Handler: { _, _ in
                .success(<Feature>Page(items: [], pagination: Pagination(offset: 0, limit: 20, total: 0)))
            },
            appLanguage: appLanguage
        )
    }

    static func <feature>ScreenNoConnectivity(
        appLanguage: AppLanguage = .english
    ) -> some View {
        <feature>Screen(
            fetch<Model>Handler: { _, _ in .failure(.noConnectivity) },
            appLanguage: appLanguage
        )
    }

    // Optional: add a card/row-level preview helper
    static func <feature>RowView(
        <model>: <Model> = .mock,
        appLanguage: AppLanguage = .english
    ) -> some View {
        <Feature>RowView(<model>: <model>)
            .padding(AppSpacing.medium)
            .environment(\.locale, appLanguage.locale)
    }
}
```

### Named Previews in the Screen File

Every `<Feature>Screen` must include **at least three named `#Preview` blocks** covering the core visual states. All previews go through `PreviewContainer` — never instantiate a ViewModel directly.

```swift
// At the bottom of <Feature>Screen.swift
#Preview("Success") {
    PreviewContainer.<feature>Screen()
}

#Preview("Empty") {
    PreviewContainer.<feature>ScreenEmpty()
}

#Preview("No Connectivity") {
    PreviewContainer.<feature>ScreenNoConnectivity()
}
```

> **Rule:** A single unnamed `#Preview` is not sufficient. Named previews make it easy to validate each visual state in the Xcode canvas without modifying mock data manually.

---

## Step 4 — Unit Tests

Read `.claude/skills/write-tests/SKILL.md` in full before writing any test.

See `templates/tests.swift` for full boilerplate. Required test suites:

### `PurchasesViewModelTests` (or `<Feature>ViewModelTests`)

Full coverage of all state transitions — see below. Framework is Swift Testing; `@MainActor @Suite`. Each test exercises one behavior.

**Mandatory behaviours to test:**

| Category | What to test |
|---|---|
| Initial state | `state == .loading` on creation |
| `onAppear` – analytics | `screenShowed` tracked exactly once even when called multiple times |
| `onAppear` – success | `state == .loaded(items, hasMore: false)` when page total == count |
| `onAppear` – hasMore | `state == .loaded(items, hasMore: true)` when total > count |
| `onAppear` – empty | `state == .empty` when API returns 0 items |
| `onAppear` – each error | One test per `FetchError` case (`unauthorized`, `serverError`, etc.) |
| `onAppear` – idempotent | `fetchCallCount == 1` after calling `onAppear()` twice |
| `loadMore` – success | Appends next page; `hasMore` reflects whether more pages exist |
| `loadMore` – full mapping | Test with `count >= 3` items to verify full list concatenation, not just first/last |
| `loadMore` – error | Reverts to `.loaded(previousItems, hasMore: true)` |
| `loadMore` – noop when loading | No fetch when `state == .loading` |
| `loadMore` – noop when exhausted | No fetch when `hasMore == false` |
| `loadMore` – correct offset | `capturedOffset == previousItems.count` |
| `refresh` – success | Replaces list with fresh data |
| `refresh` – empty | `state == .empty` when API returns 0 items |
| `refresh` – error with data | Reverts to `.loaded(previousItems, hasMore: true)` |
| `refresh` – error from empty | `state == .error(…)` |
| `refresh` – requests offset 0 | `capturedOffset == 0` |

### `<Feature>AnalyticsEventTests`

One test per `name` value and one test per `properties` shape.

### `<Feature>ViewModelState+Equatable.swift` (test support)

Add to `ClickNBackTests/Support/` — enables `#expect(sut.state == .loaded(...))` assertions.

```swift
// ClickNBackTests/Support/<Feature>ViewModelState+Equatable.swift
@testable import ClickNBack

extension <Feature>ViewModel.State: @retroactive Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.empty, .empty): return true
        case (.loaded(let li, let lh), .loaded(let ri, let rh)): return li == ri && lh == rh
        case (.loadingMore(let l), .loadingMore(let r)): return l == r
        case (.refreshing(let l), .refreshing(let r)): return l == r
        case (.error(let l), .error(let r)): return l == r
        default: return false
        }
    }
}
```

> **Note:** This file requires `@testable import ClickNBack` — the ViewModel's `State` is not `public`. The Equatable conformance on the domain model (e.g. `Purchase`) must use `public nonisolated static func ==` to avoid a "main actor-isolated conformance cannot be used in nonisolated context" error caused by `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. If the domain model has a synthesized `Equatable` (from `struct … : Equatable`), replace it with an explicit `nonisolated` extension like `Offer` does.

---

## Step 5 — Design System Rules

### Colors (`AppColors`)

**Prefer system-adaptive tokens** — reach for these first:
- Backgrounds: `AppColors.Background.{primary,secondary,tertiary}`
- Text: `AppColors.Text.{primary,secondary,tertiary,disabled}`
- Borders: `AppColors.Border.border`
- Status: `AppColors.Status.{success,warning,error}`
- Semantic: `AppColors.Semantic.{primary,secondary}`

**Status badge pattern** (used for `PurchaseStatus`, offer state, etc.):
```swift
Text(statusLabel)
    .font(AppTypography.Label.medium)
    .foregroundStyle(statusColor)
    .padding(.horizontal, AppSpacing.compact)
    .padding(.vertical, AppSpacing.minimal)
    .background(statusColor.opacity(0.12))
    .clipShape(Capsule())
```

**Custom colors need light/dark variants** — use a `UIColor` trait-collection closure; never use a plain `Color(red:green:blue:)` literal.

### Card/Row Layout

Follow the `OfferCardView` / `PurchaseRowView` pattern:
- `HStack(alignment: .top, spacing: AppSpacing.medium)` for icon + content
- Card background: `.background(AppColors.Background.secondary)` + `.clipShape(RoundedRectangle(cornerRadius: AppDimensions.CornerRadius.large))` + `.overlay(RoundedRectangle(…).stroke(AppColors.Border.border, lineWidth: AppDimensions.Border.small))`
- Spacing inside a card: `VStack(alignment: .leading, spacing: AppSpacing.compact)` with `.padding(AppSpacing.medium)`

---

## Step 6 — Validate

**The task is not complete until `make qa-gates` passes green.** Run in order:

```bash
make generate   # register new files with Tuist — required after any file creation or deletion
make build      # fast compilation check
make test       # unit tests only — fast feedback
make qa-gates   # full pipeline: build + lint + lint-md + all tests + coverage
```

Fix every error and warning before considering the work done.
