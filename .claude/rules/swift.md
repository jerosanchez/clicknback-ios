---
paths:
  - "**/*.swift"
---

## Swift 6 & Concurrency

- `@MainActor` is set **project-wide** (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`) — assume all code runs on the main actor unless explicitly otherwise
- Never add `@unchecked Sendable` or `nonisolated(unsafe)` — fix the underlying concurrency issue properly
- `async/await` only — no Combine, no callbacks, no `DispatchQueue`
- `Result<Success, Failure: Error>` with typed failure for all async operations

## Types & Patterns

- `@Observable` on ViewModels — never `ObservableObject` / `@Published`
- `struct` for models; `final class` for ViewModels, repositories, and use cases
- Protocol defined in `Data/` or `Platform/`, implemented in `Infra/`, always consumed as the protocol type
- **APIRequest enums** must be `public`, with all properties `public`
- Standard ViewModel state pattern:
  ```swift
  enum State { case idle, loading, success, error(SomeError) }
  ```

## Layer Boundaries (non-negotiable)

- **Features** must not import Infra types directly
- **Data** (use cases) must not import Infra
- **`Main/Composition/`** is the only place all layers meet
- All dependencies injected via constructor — no singletons, no service locators

## Design System — Never Hardcode

| What | Use |
|---|---|
| Colors | `AppColors` |
| Spacing | `AppSpacing` |
| Typography | `AppTypography` |
| Icons | `AppIcons` |
| Sizes | `AppDimensions` |

## Localization

- Never hardcode user-facing strings — use `.xcstrings` catalog + `L10nKey+<feature>.swift`

## Security

- Access/refresh tokens in **secure storage** only (`CompositionRoot.secureStorage`) — never `UserDefaults`
- Never log credentials, tokens, or PII
- Never surface raw 4xx/5xx server messages to the user

## Tuist

- Never edit `project.pbxproj` by hand
- Run `make generate` after creating, moving, or deleting Swift files
