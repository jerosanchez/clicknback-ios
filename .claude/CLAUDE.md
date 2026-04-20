# ClickNBack iOS

## Project Overview

ClickNBack is an iOS app built with **SwiftUI** and **Swift 6 strict concurrency**, targeting **iOS 26.0+**. The Xcode project is managed with **Tuist** — never edit `project.pbxproj` by hand; run `make generate` after creating or moving files.

---

## Architecture: Clean Architecture + MVVM

Strict **inward dependency rule** — dependencies only point inward:

```
Features (MVVM)          SwiftUI Views + @Observable ViewModels
     ↓ uses protocols from
Data (Domain)            Use Cases, Repository protocols, domain models, error types
     ↓ implemented by
Infra (Infrastructure)   Remote repositories, PublicAPIClient, UserDefaultsStorage, etc.
     ↕ wired at
Main/Composition         CompositionRoot.swift + Container views (only place layers meet)
```

**`Platform/`** holds cross-cutting concern **protocols only** (`APIClient`, `KeyValueStorage`, `Logger`, `AnalyticsTracker`, `AnalyticsEvent`). Concrete implementations live in `Infra/Platform/`.

### Layer Rules (non-negotiable)

- **Features** depend only on **Data** protocols — never import Infra types directly
- **Data** (use cases) depend only on **Platform** protocols — never import Infra
- **Infra** implements Data and Platform protocols
- **`Main/Composition/`** is the **only** place that wires across all layers
- All dependencies flow **inward via constructor injection** — no singletons, no service locators

---

## Folder Structure

```
ClickNBack/
├─ Core/DesignSystem/           Design tokens: AppColors, AppSpacing, AppTypography, AppIcons, AppDimensions
├─ Data/<Feature>/              Repository protocols, Use Cases, domain models, typed errors
├─ Features/<Feature>/          Screen + ViewModel + Subviews + Analytics event enum + L10n
├─ Infra/
│   ├─ Platform/                Concrete impls: PublicAPIClient, UserDefaultsStorage, ConsoleLogger, …
│   └─ Repositories/<Feature>/  RemoteXxxRepository + method extensions + APIRequest enum
├─ Platform/                    Cross-cutting protocols: APIClient, KeyValueStorage, Logger, AnalyticsTracker
├─ Main/
│   ├─ AppConfig.swift          Environment enum + baseURL per environment
│   ├─ AppState.swift           @Observable global app state
│   ├─ ClickNBackApp.swift      @main entry point
│   └─ Composition/             CompositionRoot.swift + <Screen>Container.swift per feature
└─ Support/
    ├─ Mocks/                   Public reusable mocks (tests AND SwiftUI previews)
    └─ Preview/                 SwiftUI preview helpers and sample data
```

---

## Naming Conventions

| Component | Pattern | Example |
|---|---|---|
| Repository protocol | `<Feature>Repository` | `AuthRepository` |
| Remote implementation | `Remote<Feature>Repository` | `RemoteAuthRepository` |
| Method extension file | `Remote<Feature>Repository+<method>.swift` | `RemoteAuthRepository+login.swift` |
| Use case | `<Action>UseCase` | `LoginUseCase` |
| ViewModel | `<Screen>ViewModel` | `SignInViewModel` |
| Screen | `<Screen>Screen` | `SignInScreen` |
| Composition container | `<Screen>Container` | `SignInContainer` |
| Analytics enum | `<Feature>AnalyticsEvent` | `SignInAnalyticsEvent` |
| Storage key enum | `<Feature>StorageKey` | `AuthTokenStorageKey` |
| Mock | `Mock<Protocol>` | `MockAuthRepository` |
| API request enum | `<Feature>APIRequest` | `AuthAPIRequest` |

---

## Swift Patterns & Conventions

- **`@Observable`** on ViewModels — never `ObservableObject`
- **`@MainActor`** on all ViewModels and Views (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` is set project-wide)
- **`Result<Success, Failure: Error>`** for all async operations with typed failure
- **`async/await`** only — no Combine, no callbacks
- **Value types** (`struct`) for models; **`final class`** for ViewModels and repositories
- **Protocol-first**: define protocol in `Data/` or `Platform/`, implement in `Infra/`, consume the protocol
- Standard ViewModel state pattern:
  ```swift
  enum State { case idle, loading, success, error(SomeError) }
  ```
- Avoid `@unchecked Sendable` and `nonisolated(unsafe)` — fix the concurrency issue properly

---

## Build & Test Commands

```bash
make build              # Debug build for simulator
make test               # Unit tests only (fast — use during development)
make test-integration   # Integration tests only
make test-all           # Full suite (unit + integration)
make coverage           # Coverage report (minimum threshold: 65%)
make lint               # SwiftLint
make lint-md            # Markdown lint (markdownlint-cli) — run after editing any .md file
make format             # SwiftFormat
make qa-gates           # Full pipeline: build + lint + lint-md + all tests + coverage
make generate           # Regenerate Xcode project from Project.swift (Tuist)
```

**Always run `make qa-gates` before committing.**

---

## Testing

See the `write-tests` skill for full guidelines. Quick reference:

- Framework: **Swift Testing** — `import Testing`, `#expect()`, `@Suite`, `@Test`
- `@MainActor` on every test suite — one behavior per test
- Public mocks in `ClickNBack/Support/Mocks/` — no private inline mocks
- No `@testable import` — all types under test must be `public`

---

## Design System

**Never hardcode colors, spacing, font sizes, or icons.** Always use:

- `AppColors` — semantic color tokens
- `AppSpacing` — spacing scale
- `AppTypography` — text styles
- `AppIcons` — icon names/constants
- `AppDimensions` — size constants

---

## Localization

- One `.xcstrings` catalog per feature in `Features/<Feature>/`
- L10n key enum: `L10nKey+<feature>.swift`
- **Never hardcode user-facing strings**

---

## Analytics

- One `<Feature>AnalyticsEvent: AnalyticsEvent` enum per feature
- `AnalyticsTracker` injected into ViewModel via constructor
- Always track screen-appear events in `onAppear()`
- Never log PII, credentials, or tokens in analytics events

---

## Security

- Access tokens and refresh tokens use **secure storage** (`CompositionRoot.secureStorage`) — never `UserDefaults`
- Never log credentials or tokens
- API 4xx/5xx error details must not surface raw server messages to the user

---

## Common Pitfalls

- **Don't edit `project.pbxproj`** — run `make generate` after creating files
- **Don't import across layers** — Features must not import Infra types
- **Don't wire dependencies inside Views** — use a `Container` view in `Main/Composition/`
- **Don't use `UserDefaults` for tokens** — use `CompositionRoot.secureStorage`
- **Don't add private inline mocks** — add to `ClickNBack/Support/Mocks/` for reuse

---

## Skills

| Skill | Description |
|---|---|
| `write-tests` | Write tests following project conventions |
| `build-feature` | Scaffold a complete new feature end-to-end |
| `analyze-bug` | Trace and debug a reported issue |
| `analyze-performance` | Profile and improve performance |
| `write-docs` | Generate DocC documentation |
| `review-pr` | Review current branch changes (uses live `git diff`) |
| `create-issue` | Create a GitHub issue via MCP |

## Agents

| Agent | Description |
|---|---|
| `ios-reviewer` | Read-only code review with structured report |
