# Agent Instructions

## Unit Testing Guidelines

### Test Naming Convention

Tests must follow the naming pattern:
- `<methodName>_returns_<result>_on_<condition>` — for testing return values (e.g., `execute_returnsSuccess_onValidCredentials`)
- `<methodName>_<sideEffect>_on_<condition>` — for testing side effects (e.g., `execute_storesTokens_onValidCredentials`)
- The test name should **reflect the expected behavior**, not the implementation

### AAA Pattern (Arrange-Act-Assert)

Every test must follow the **AAA pattern** with explicit comments:
- **Arrange:** Set up test data, mocks, and the System Under Test (SUT)
- **Act:** Invoke the method being tested with minimal, focused action
- **Assert:** Verify the expected outcome

### One Behavior Per Test

Each test must verify **one discrete behavior**:
- **Return value** → separate test
- **Side effects** (storage, logging, API calls) → separate test per effect
- **Error cases** → one test per error type

### Mock All External Dependencies

- Never use real implementations in tests
- Inject all dependencies as mock instances
- Prefer **shared `public` mocks** in `ClickNBack/Support/Mocks/` over per-file private mocks — they can be reused by both tests and previews without `@testable import`
- Only create a private local mock when the shared one genuinely cannot cover the scenario
- Mocks should implement only the protocol methods needed for testing
- Mocks should allow configuration of return values and error conditions
- Use meaningful names: `MockAuthRepository`, `MockKeyValueStorage`, etc.

### Import Style

- Use `import ClickNBack` (plain import) in test files — shared mocks are `public` so no special access is needed
- **Never use `@testable import`** unless there is absolutely no other option (e.g., testing a `internal` type that cannot be made `public`)

### SUT Factory Method `makeSUT()`

Extract SUT instantiation to a private factory method with default values:
- Reduces code duplication in test setup
- Allows tests to provide specific dependencies for scenarios
- Makes the `Arrange` section cleaner and more readable
- Default dependency values should represent the "happy path"

### Helper Factory Methods

Create factory methods for frequently-used test dependencies (mocks, models) using the `make<Type>()` naming pattern:
- **Name pattern:** `make<Type>()` (e.g., `makeAPIClient()`, `makeLoginCredentials()`)
- **Parameters:** Accept optional parameters with sensible defaults for customization
  - Example: `makeAPIClient(response: LoginSuccessResponse = default, endpoint: String = default)`
- **Purpose:** Allow tests to easily create variations without duplicating setup code
- **Flexibility:** Default values cover the happy path; tests override only what they need
- Example in `RemoteAuthRepositoryLoginTests`:
  ```swift
  private func makeAPIClient(
      response: LoginSuccessResponse = LoginSuccessResponse(...),
      endpoint: String = "v1/auth/login"
  ) -> MockAPIClient { ... }
  ```

### Test Data and Values

- Avoid hardcoding literal strings in assertions or setup
- Extract test values from arranged variables (e.g., `tokens.accessToken` instead of `"access-token"`)
- Use production enums and constants (e.g., `AuthTokensStorageKey.authAccessToken.rawValue`)
- This ensures tests stay synchronized with actual values and improves maintainability

### Code Organization

- Place all test methods at the top of the test suite (after properties)
- Place helper methods in a `// MARK: - Helpers` section at the end, before mocks
- Place mock implementations in a `// MARK: - Mocks` section at the very end
- This creates a clear visual hierarchy: tests → helpers → mocks

### Test File Placement

Test files must mirror the production code structure under `ClickNBackTests/Unit/`:
- **Data layer tests:** `ClickNBackTests/Unit/Data/*` — test use cases, repositories, and models
- **Infra layer tests:** `ClickNBackTests/Unit/Infra/Repositories/` — test remote/local repositories
- **Feature layer tests:** `ClickNBackTests/Unit/Features/*/` — test screens and view models
- Integration tests go under `ClickNBackTests/Integration/` mirroring the same structure
- Test file naming: `<ClassName>+<MethodName>Tests.swift` or `<ClassName>Tests.swift`
- Example: Repository login method tested in `ClickNBackTests/Unit/Infra/Repositories/Auth/RemoteAuthRepositoryLoginTests.swift`

### Assertion Best Practices

- Use **`#expect()`** from Swift Testing framework
- Keep assertions minimal and readable
- Assert on meaningful values, not implementation details
- One main assertion per test (multiple assertions only if testing a single logical behavior)

---

## Running Tests

The test suite is split into **unit** and **integration** tests. Use the appropriate target:

| Command | What it runs | When to use |
|---|---|---|
| `make test` | Unit tests only (excludes integration) | Daily development — fast feedback loop |
| `make test-integration` | Integration tests only | Verifying integration layer in isolation |
| `make test-all` | Full suite (unit + integration) | Before committing; CI/CD pipelines |

- Do not use `xcodebuild test` directly unless debugging a specific issue
- This ensures consistency across development, code review, and pipeline environments

### Test File Placement by Kind

Test files are split between two Xcode targets, each driven by a top-level folder:

- **`ClickNBackTests/Unit/`** → compiled into the `ClickNBackTests` target (`make test`)
  - Mirror the production folder structure inside `Unit/` (e.g., `Unit/Features/Auth/SignInViewModelTests.swift`)
- **`ClickNBackTests/Integration/`** → compiled into the `ClickNBackIntegrationTests` target (`make test-integration`)
  - Mirror the production folder structure inside `Integration/` (e.g., `Integration/Features/Auth/SignInIntegrationTests.swift`)
- **`ClickNBackTests/Support/`** → shared by both targets (test helpers, `MockURLProtocol`, test-only type extensions)

Dropping a file in the right folder is all that is needed — the Makefile and Xcode targets never need updating.

---

## Quality Assurance Gates

- Always run `make qa-gates` after each change to ensure nothing is broken
- This runs the complete quality assurance pipeline: build, all tests (unit + integration), coverage check, and lint
- Do not commit or submit pull requests without passing `make qa-gates`
- This ensures consistency across development, code review, and pipeline environments

### Coverage Gate

- After writing or modifying any tests, run `make coverage` to check the current coverage level
- The minimum passing threshold is currently **65%** — coverage below this will fail `make qa-gates`
- Aim to keep coverage trending upward; the long-term target is **75%**
- To check coverage manually at a custom threshold: `make coverage MIN_COVERAGE=75`
- Coverage tiers reported by the tool:
  - ❌ **Poor** — below 60%
  - ⚠️ **Almost there** — 60% to minimum
  - ✅ **Passed** — meets minimum but below 75%
  - 🚀 **Exceeds expectations** — 75% or above
