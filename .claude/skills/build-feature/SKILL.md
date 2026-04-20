---
name: build-feature
description: Scaffold a complete new feature end-to-end following Clean Architecture + MVVM. Use when asked to build a new screen, feature, or module.
disable-model-invocation: true
argument-hint: [feature name, e.g. "Wallet history"]
---

Scaffold feature: $ARGUMENTS

## Workflow

1. **Plan** — Read a similar existing feature (e.g. `Auth/`, `Offers/`) to understand patterns; identify models, operations, screens, and analytics events
2. **Domain** (`ClickNBack/Data/<Feature>/`) — Create repository protocol, domain model(s), typed error enum, and use case(s); use `templates/domain.swift` as a starting point
3. **Infra** (`ClickNBack/Infra/Repositories/<Feature>/`) — Create `<Feature>APIRequest.swift`, `Remote<Feature>Repository.swift` skeleton, and one `+<method>.swift` extension per operation; use `templates/infra.swift`
4. **Feature** (`ClickNBack/Features/<Feature>/`) — Create ViewModel (with `State` enum), Screen, subviews, analytics event enum, and `.xcstrings` catalog; use `templates/feature.swift`
   - **Views `#Preview`**: always via `PreviewContainer` — add a `static func <screen>Screen(...)` extension in `ClickNBack/Support/Preview/Container/PreviewContainer+<feature>.swift` and call it from the `#Preview` block; never instantiate the ViewModel directly inside `#Preview`
5. **Composition** (`ClickNBack/Main/Composition/`) — Add `<Screen>Container.swift` and wire in `CompositionRoot.swift`; use `templates/composition.swift`
6. **Mock** (`ClickNBack/Support/Mocks/`) — Add `Mock<Feature>Repository.swift` (public, configurable via handler closures)
7. **Tests** — Follow the `write-tests` skill for unit + integration coverage of use case, ViewModel, and repository
8. **Validate** — Run `make generate` (new files added), then `make qa-gates`

## Design System Rules

### Colors (`AppColors`)

**Prefer system-adaptive tokens** — reach for these first; they handle light/dark automatically:
- Backgrounds: `AppColors.Background.{primary,secondary,tertiary}` (→ `systemBackground`, etc.)
- Text: `AppColors.Text.{primary,secondary,tertiary,disabled}` (→ `label`, `secondaryLabel`, etc.)
- Borders: `AppColors.Border.border` (→ `separator`)
- Overlays: `AppColors.Overlay.{light,medium,heavy}` (→ `.black.opacity(...)`)
- Status: `AppColors.Status.{success,warning,error}`

**Custom colors always need light/dark variants** — when a system token doesn't exist (e.g. a new brand color), use a `UIColor` trait-collection closure:

```swift
static var myColor: Color = .init(UIColor { traitCollection in
    traitCollection.userInterfaceStyle == .dark
        ? UIColor(red: ..., green: ..., blue: ..., alpha: 1.0)  // dark value
        : UIColor(red: ..., green: ..., blue: ..., alpha: 1.0)  // light value
})
```

Never use a plain `Color(red:green:blue:)` literal for a token that will appear on both light and dark backgrounds — it will look wrong in one of the two modes.

