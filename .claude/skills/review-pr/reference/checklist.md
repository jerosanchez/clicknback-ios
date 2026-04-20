# PR Review Checklist

## Architecture

- [ ] Inward dependency rule respected — Features → Data → Infra, never reversed
- [ ] New dependencies injected via constructors — no `static` singletons, no service locators
- [ ] New protocols defined in `Platform/` or `Data/`, not in `Infra/` or `Features/`
- [ ] Container views in `Main/Composition/` wire dependencies — not inside Views or ViewModels

## Naming & Conventions

- [ ] `Remote<Feature>Repository`, `<Action>UseCase`, `<Screen>ViewModel`, `<Screen>Screen`, `<Screen>Container`
- [ ] Long method implementations in extension files: `<Type>+<method>.swift`
- [ ] Design system used: `AppColors`, `AppSpacing`, `AppTypography` — no hardcoded values
- [ ] No hardcoded user-facing strings — uses `.xcstrings` and `L10nKey`
- [ ] Analytics: screen-appear events tracked in `onAppear()`

## Swift 6 / Concurrency

- [ ] `@MainActor` on all ViewModels and Views
- [ ] No `@unchecked Sendable` without a documented reason
- [ ] No `nonisolated(unsafe)` without a documented reason
- [ ] Long-lived `Task`s stored and cancelled when owner is deallocated
- [ ] Closures capturing `self` use `[weak self]`
- [ ] `async/await` only — no Combine, DispatchQueue, or callbacks

## Testing

- [ ] All new public types have unit test coverage
- [ ] Tests follow AAA with `// Arrange`, `// Act`, `// Assert` comments
- [ ] One behavior per test — return values and side effects in separate tests
- [ ] New mocks added to `ClickNBack/Support/Mocks/` (not per-file inline mocks)
- [ ] Test names follow `<method>_returns<Result>_on<Condition>` pattern
- [ ] No `@testable import` used

## Security

- [ ] Tokens stored in `CompositionRoot.secureStorage` — not `UserDefaults`
- [ ] No credentials or tokens logged via `Logger`
- [ ] No PII in analytics events
- [ ] Raw server error messages not surfaced in UI error states
