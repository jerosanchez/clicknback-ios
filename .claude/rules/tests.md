---
paths:
  - "**/*Tests.swift"
  - "ClickNBackTests/**/*.swift"
---

## Critical: Always Run `make generate` Before Tests

**When you create, move, or delete test files:**
1. Run `make generate` to regenerate the Xcode project with Tuist
2. Then run `make test`

Without `make generate`, new test files are not included in the Xcode project build, causing "cannot find in scope" compilation errors even if imports and code are correct.

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

## Mocks & Factory Methods

- **Public** shared mocks live in `ClickNBack/Support/Mocks/` — no private inline mocks
- Naming: `Mock<Protocol>` (e.g., `MockAuthRepository`, `MockKeyValueStorage`)
- Use `make<Type>()` helpers with sensible defaults; override only what the test requires
- **APIClient factory pattern**: For repository tests, provide `makeAPIClient(response:endpoint:)` with defaults:
  ```swift
  private func makeAPIClient(
      response: SomeResponse = SomeResponse(...), // concrete default
      endpoint: String = "v1/some-endpoint"
  ) -> MockAPIClient {
      let client = MockAPIClient()
      client.setMockResponse(response, for: endpoint)
      return client
  }
  ```
  Tests inject via `makeSUT(apiClient:)` — only pass custom apiClient for non-default scenarios.

## APIRequest Enum Tests

**Production code requirements:**
- Every `<Feature>APIRequest` enum must be declared `public`
- All properties (`method`, `endpoint`, `headers`, `queryParams`, `body`) must be declared `public` to satisfy protocol conformance
- This ensures tests can use `import ClickNBack` without `@testable import`

**Test requirements:**
- Every `<Feature>APIRequest` enum must have a corresponding `<Feature>APIRequestTests.swift` file
- Test each property for every enum case
- Naming: `<property>_returns<Value>_for<CaseName>Case`
- For collections in properties (e.g., queryParams), test:
  - All expected keys are present
  - Correct values are mapped
  - No extra keys exist (count check)
  - Edge cases (zero values, large values, empty strings)
- Example:
  ```swift
  @Test
  func queryParams_containsOffsetAndLimit_forListActiveCase() {
      let sut = OffersAPIRequest.listActive(offset: 10, limit: 50)
      #expect(sut.queryParams?["offset"] == "10")
      #expect(sut.queryParams?["limit"] == "50")
  }

  @Test
  func queryParams_containsOnlyOffsetAndLimit_forListActiveCase() {
      let sut = OffersAPIRequest.listActive(offset: 0, limit: 20)
      #expect(sut.queryParams?.count == 2)
  }
  ```

## Test Data — IDs and List Mapping

- **Use realistic UUIDs for models with `id` fields** — use `UUID().uuidString` in helper defaults. Avoid synthetic IDs like `"user-1"` or `"offer-id"` as they can hide bugs (e.g., off-by-one errors in mapping).
- **For list operations, test mapping all items** — add at least one test with multiple items (≥3) to verify the full list is mapped correctly. This catches bugs where only the first or last element is processed. Example: if testing a `fetchActiveOffers` endpoint, include a test with 3+ offers and verify all are present in the result.

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
