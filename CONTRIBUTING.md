# Contributing

## Prerequisites

- **Xcode 26.4+** — [Mac App Store](https://apps.apple.com/app/xcode/id497799835?mt=12)
- **Homebrew** — <https://brew.sh>
- **Tuist**, **SwiftFormat**, **SwiftLint**, **markdownlint-cli** (installed automatically below)

## Setup

```sh
make install   # installs tools and generates the Xcode project
make open      # opens the workspace in Xcode
```

## Build & Run

1. Select the **`ClickNBack-Dev`** scheme in Xcode
2. Choose a simulator (default: iPhone 17)
3. Press **Run** (▶)

## Development Workflow

| Command | Purpose |
| --- | --- |
| `make build` | Debug build for simulator |
| `make test` | Unit tests only (fast — use during development) |
| `make test-integration` | Integration tests only |
| `make test-all` | Full suite (unit + integration) |
| `make coverage` | Coverage report (minimum threshold: 65%) |
| `make lint` | SwiftLint |
| `make lint-md` | Markdown lint (markdownlint-cli) |
| `make format` | SwiftFormat |
| `make qa-gates` | Full pipeline: build + lint + all tests + coverage |

**Always run `make qa-gates` before committing.**

## Architecture

The codebase follows Clean Architecture + MVVM with six layers:

```text
ClickNBack/
├─ Core/DesignSystem/       Design tokens (AppColors, AppSpacing, AppTypography, …)
├─ Data/<Feature>/          Repository protocols, use cases, domain models, typed errors
├─ Features/<Feature>/      Screen + ViewModel + Subviews + Analytics + L10n
├─ Infra/
│   ├─ Platform/            Concrete impls: PublicAPIClient, UserDefaultsStorage, …
│   └─ Repositories/        RemoteXxxRepository + APIRequest enums
├─ Platform/                Cross-cutting protocols: APIClient, KeyValueStorage, Logger, …
└─ Main/
    ├─ AppConfig.swift       Environment enum + baseURL per environment
    ├─ AppState.swift        @Observable global app state
    ├─ ClickNBackApp.swift   @main entry point
    └─ Composition/          CompositionRoot.swift + <Screen>Container.swift per feature
```

**Dependency rule**: Features → Data → Infra → Platform. `Main/Composition/` is the only place layers are wired together. Never import across layer boundaries.

## Code Quality

- Run `make format` to auto-format before committing
- Run `make lint` to check for SwiftLint violations
- Run `make qa-gates` as the final check — it must pass before any PR

Coverage minimum is **65%**; long-term target is **75%**.

## Project Maintenance

| Command | Purpose |
| --- | --- |
| `make generate` | Regenerate Xcode project from `Project.swift` (run after creating/moving files) |
| `make clean-artifacts` | Remove build artifacts |
| `make clean-all` | Full cleanup (artifacts + derived data) |

Never edit `project.pbxproj` by hand — always use `make generate`.
