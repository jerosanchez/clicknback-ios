![ClickNBack banner](/docs/clicknback-banner-bg-white.png)

[![CI](https://github.com/jerosanchez/clicknback-ios/actions/workflows/ci.yml/badge.svg)](https://github.com/jerosanchez/clicknback-ios/actions/workflows/ci.yml)
[![Xcode](https://img.shields.io/badge/Xcode-26.4%2B-blue?logo=xcode)](https://developer.apple.com/xcode/)
[![Swift](https://img.shields.io/badge/Swift-6.0%2B-orange?logo=swift)](https://swift.org)

Native iOS client for the [ClickNBack cashback platform](https://github.com/jerosanchez/clicknback). Users earn cashback on purchases at partner merchants — this app lets them browse offers, track their wallet, and manage their profile.

---

## Architecture

The app follows **Clean Architecture + MVVM** with strict inward dependency rules across five layers:

```text
Features (MVVM)     SwiftUI views + @Observable ViewModels
       ↓
Data (Domain)       Use cases, repository protocols, domain models
       ↓
Infra               Remote repositories, API client, storage implementations
       ↕
Main/Composition    CompositionRoot — the only place layers are wired together
       ↕
Platform            Cross-cutting protocols: APIClient, KeyValueStorage, Logger, Analytics
```

- **Swift 6** strict concurrency — `@MainActor` applied project-wide
- **SwiftUI** only, targeting **iOS 26.0+**
- **Tuist** manages the Xcode project (`Project.swift` → `make generate`)
- **Swift Testing** for all tests (`import Testing`, never XCTest)

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup, development workflow, and code quality gates.
