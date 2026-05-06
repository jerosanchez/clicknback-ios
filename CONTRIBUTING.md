# Contributing to ClickNBack iOS

---

## Setup

### Prerequisites

- **Xcode 26.4+** — [Mac App Store](https://apps.apple.com/app/xcode/id497799835?mt=12)
- **Homebrew** — <https://brew.sh>
- **Tuist**, **SwiftFormat**, **SwiftLint**, **markdownlint-cli** (installed automatically below)

### First-Time Setup

```sh
make install   # installs tools and generates the Xcode project
make open      # opens the workspace in Xcode
```

Then select the **`ClickNBack-Dev`** scheme, choose a simulator, and press **Run** (▶).

---

## How to Contribute

1. **Create a GitHub issue** — use `/project:create-issue` to scaffold it; align on scope before writing any code
2. **Work in small, atomic chunks** — one feature per PR, one concern per commit
3. **Use AI skills for implementation** — let the tools handle boilerplate and tests (see skills below)
4. **Run `make qa-gates` before pushing** — CI enforces the same gates; failing them blocks merging
5. **Open a PR** — reference the issue, then run `/project:review-pr` for a self-review before requesting human review
6. **Wait for CI + code review** — once approved and CI passes, merge and delete the branch

---

## AI Skills

This project is AI-assisted. All skills live in `.claude/skills/` and are invoked with `/project:<skill>`:

| Skill | When to use |
| --- | --- |
| `/project:build-data-layer` | Scaffold use cases, repository protocols, domain models, mocks, and tests for a new feature |
| `/project:build-infra-layer` | Scaffold API request enum, DTOs, remote repository, and infra tests |
| `/project:write-tests` | Generate Swift Testing suites following AAA structure and project conventions |
| `/project:analyze-bug` | Trace, debug, and fix a reported issue |
| `/project:analyze-performance` | Profile and improve performance |
| `/project:write-docs` | Generate DocC documentation for protocols, use cases, or ViewModels |
| `/project:create-issue` | Scaffold a well-formed GitHub issue from a description |
| `/project:review-pr` | Run a structured code review against the current branch diff |

For architecture, naming conventions, Swift patterns, and testing standards, the AI loads `.claude/CLAUDE.md` automatically — no need to repeat them here.

---

## Development Commands

| Command | Purpose |
| --- | --- |
| `make build` | Debug build for simulator |
| `make test` | Unit tests only (fast — use during development) |
| `make test-integration` | Integration tests only |
| `make test-all` | Full suite (unit + integration) |
| `make coverage` | Coverage report (informational — not yet a hard gate, see [#6](https://github.com/jerosanchez/clicknback-ios/issues/6)) |
| `make lint` | SwiftLint |
| `make lint-md` | Markdown lint |
| `make format` | SwiftFormat |
| `make qa-gates` | Full pipeline: build + lint + all tests — **run before every push** |
| `make generate` | Regenerate Xcode project from `Project.swift` (run after adding/moving files) |
| `make clean-all` | Full cleanup: build artifacts + Tuist cache + regenerated project |

---

## Best Practices

- **Issue first, code second** — no untracked work; every PR references an issue
- **Let AI handle boilerplate** — use skills for scaffolding, tests, and docs; focus your attention on business logic and design decisions
- **Never skip `make qa-gates`** — format, lint, and all tests before every push
- **Never edit `project.pbxproj`** — always run `make generate` after adding or moving files
- **Never import across layers** — Features must not import Infra; check the dependency rule in `.claude/CLAUDE.md`
- **Never hardcode design tokens** — use `AppColors`, `AppSpacing`, `AppTypography`, etc.
- **Secure storage for tokens** — never `UserDefaults`; always use `CompositionRoot.secureStorage`
- **Mocks are public and shared** — add to `ClickNBack/Support/Mocks/`, not inline in test files
