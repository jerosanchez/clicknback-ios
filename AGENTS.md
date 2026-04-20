# Agent Instructions

This project uses **Claude Code** as its primary AI development tool. All guidelines, conventions, and workflows live under `.claude/` — that is the single source of truth for AI agents working in this codebase.

## For Claude Code

The full setup is under `.claude/`:

- **`CLAUDE.md`** — architecture, layer rules, naming conventions, Swift patterns, build commands, design system, security rules
- **`rules/swift.md`** — auto-loaded for every `*.swift` file
- **`rules/tests.md`** — auto-loaded for every `*Tests.swift` file
- **`rules/markdown.md`** — auto-loaded for every `*.md` file
- **`skills/`** — write-tests, build-feature, analyze-bug, analyze-performance, write-docs, review-pr, create-issue
- **`commands/`** — slash commands that trigger skills explicitly (`/project:write-tests`, `/project:build-feature`, etc.)
- **`agents/ios-reviewer.md`** — read-only code reviewer subagent

## For Other AI Tools

Key conventions that apply regardless of tool:

- **Language:** Swift 6 strict concurrency, SwiftUI, iOS 26+, `@MainActor` project-wide
- **Architecture:** Clean Architecture + MVVM — strict inward dependency rule (Features → Data → Infra → Platform); composition only in `Main/Composition/`
- **Tests:** Swift Testing (`import Testing`), never XCTest; `@Suite`, `@Test`, `#expect()`; one behavior per test; AAA pattern (`// Arrange`, `// Act`, `// Assert`); public mocks in `ClickNBack/Support/Mocks/`; never `@testable import`
- **Test commands:** `make test` (unit only), `make test-all` (full suite), `make qa-gates` (full pipeline including lint and coverage)
- **Project generation:** Tuist — run `make generate` after creating or moving Swift files; never edit `project.pbxproj` by hand
