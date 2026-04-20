---
name: write-tests
description: Write Swift unit and integration tests following project conventions. Use when asked to write tests, add test coverage, test a new feature or fix, or validate behavior.
argument-hint: [type or feature to test]
---

Write tests for: $ARGUMENTS

## Setup

- `import Testing` + `import ClickNBack` — always; never `import XCTest`, never `@testable import`
- `@MainActor` on every `@Suite` (matches `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- Mirror production structure under `ClickNBackTests/Unit/` (integration tests under `Integration/`)
- See `templates/test-suite.swift` for file placement table, suite boilerplate, and named examples

## Naming

- Return value: `<method>_returns<Result>_on<Condition>`
- Side effect: `<method>_<sideEffect>_on<Condition>`
- One test per error type; one test per distinct side effect

## Test structure

- AAA pattern in every test: `// Arrange`, `// Act`, `// Assert` comments required
- One logical behavior per test — return value and side effects always in separate tests
- `#expect()` for assertions; `#expect(throws:)` for expected errors

## Factories

- `makeSUT(dep: MockType = MockType())` — default values cover the happy path; tests override only what they need
- `make<Type>()` for frequently used domain objects; accept optional params with sensible defaults

## Mocks

- All mocks **public** in `ClickNBack/Support/Mocks/` — no private inline mocks
- Naming: `Mock<Protocol>` (e.g. `MockAuthRepository`, `MockKeyValueStorage`)
- Configure via handler closures: `mock.loginHandler = { _ in .success(tokens) }`
- Use production enums/constants in assertions (e.g. `AuthTokenStorageKey.authAccessToken.rawValue`)

## Run & validate

- `make test` — unit tests only (daily development)
- `make test-all` — full suite (before committing)
- `make coverage` — minimum 65%; long-term target 75%
