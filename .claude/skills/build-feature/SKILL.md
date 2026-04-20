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
5. **Composition** (`ClickNBack/Main/Composition/`) — Add `<Screen>Container.swift` and wire in `CompositionRoot.swift`; use `templates/composition.swift`
6. **Mock** (`ClickNBack/Support/Mocks/`) — Add `Mock<Feature>Repository.swift` (public, configurable via handler closures)
7. **Tests** — Follow the `write-tests` skill for unit + integration coverage of use case, ViewModel, and repository
8. **Validate** — Run `make generate` (new files added), then `make qa-gates`


