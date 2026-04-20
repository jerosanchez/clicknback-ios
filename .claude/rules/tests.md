---
paths:
  - "**/*Tests.swift"
  - "ClickNBackTests/**/*.swift"
---

## Test Framework

- `import Testing` — `@Suite`, `@Test`, `#expect()`
- `@MainActor` on every test suite
- **Never `@testable import`** — all types under test must be `public`

## Naming Convention

| Testing | Pattern | Example |
|---|---|---|
| Return value | `<method>_returns<Result>_on<Condition>` | `execute_returnsSuccess_onValidCredentials` |
| Side effect | `<method>_<sideEffect>_on<Condition>` | `execute_storesTokens_onValidCredentials` |
| Error case | one test per distinct error type | `execute_returnsInvalidCredentialsError_onUnauthorized` |

## One Behavior Per Test

- Return value → separate test
- Each side effect (storage, logging, analytics) → separate test
- Each distinct error type → separate test

## Test Structure

```swift
@Suite @MainActor
struct FooTests {

    @Test func method_returnsX_onCondition() {
        // Arrange
        let sut = makeSUT()

        // Act
        let result = sut.method()

        // Assert
        #expect(result == expected)
    }

    // MARK: - Helpers

    private func makeSUT(dep: SomeDep = MockDep()) -> Foo {
        Foo(dep: dep)
    }

    private func makeFoo(value: String = "value") -> Foo {
        Foo(value: value)
    }
}
```

## Mocks

- **Public** shared mocks live in `ClickNBack/Support/Mocks/` — no private inline mocks
- Naming: `Mock<Protocol>` (e.g., `MockAuthRepository`, `MockKeyValueStorage`)
- Use `make<Type>()` helpers with sensible defaults; override only what the test requires

## File Placement

- Unit: `ClickNBackTests/Unit/<Layer>/<Feature>/<ClassName>Tests.swift`
- Integration: `ClickNBackTests/Integration/<Layer>/<Feature>/`
- Shared helpers/mocks: `ClickNBackTests/Support/`

## Run Tests

```bash
make test          # Unit only — use during daily development
make test-all      # Full suite — run before committing
make coverage      # Coverage report (min 65%)
```
