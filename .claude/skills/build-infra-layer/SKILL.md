---
name: build-infra-layer
description: Scaffold the infrastructure layer (API request enum, DTOs, remote repository skeleton, operation extensions, unit tests) for a new feature. Use after the data layer is in place (domain model, repository protocol, and error type must already exist).
argument-hint: "[Feature name and spec, or link to issue]"
---

Scaffold the infrastructure layer for: $ARGUMENTS

## What This Skill Produces

All files for `ClickNBack/Infra/Repositories/<Feature>/` plus unit tests in `ClickNBackTests/Unit/Infra/Repositories/<Feature>/`. The exact set of files depends on the feature — one `+<method>.swift` extension per repository operation, one DTO per response shape, shared DTOs extracted to `Shared/` when reused across features.

---

## Step 1 — API Request Enum (`ClickNBack/Infra/Repositories/<Feature>/`)

See `templates/api-request.swift` for full boilerplate. Rules:

- **One `public enum <Feature>APIRequest: APIRequest`** — one `case` per operation
- `endpoint` returns paths in the form `"v1/<resource>/..."` — no leading slash, no base URL
- `method` returns `.GET`, `.POST`, `.PUT`, `.DELETE` from `HTTPMethod`
- `headers` returns `nil` unless the request needs custom headers beyond what the client injects
- `queryParams` is a `[String: String]?` — all values are `String(value)`, never raw numbers
- `body` returns `[String: Any]?` — `nil` for GET requests; supply a `[String: Any]` literal for POST/PUT
- **Private endpoints** (requiring Bearer token) are routed through `PrivateAPIClient` in composition — the `APIRequest` itself is unaware of auth

---

## Step 2 — DTOs

See `templates/dtos.swift` for full boilerplate. Rules:

- DTOs are `public struct … : Decodable` — never `Encodable` unless the same type is sent back to the API
- Use `CodingKeys` with snake_case → camelCase mapping for every field that differs
- **Monetary amounts → `String`** in DTOs — the API returns decimal strings; the mapper converts to `Decimal` when building the domain model
- **Dates → `String`** in DTOs — ISO 8601 parsing is done in the mapper, not in the DTO (no custom `init(from:)` for dates)
- **Status fields → `String`** in DTOs — the mapper converts to the typed domain enum; if the raw value is unknown, default to a safe fallback (e.g. `.pending`) rather than crashing
- **Reusable DTOs** — if a DTO is used by multiple feature repositories (e.g. `PaginationResponse`), extract it to `ClickNBack/Infra/Repositories/Shared/`; feature-specific response wrappers stay in the feature folder
- One file per DTO type; do not bundle multiple unrelated DTOs in one file

---

## Step 3 — Remote Repository

See `templates/remote-repository.swift` for full boilerplate. Rules:

- **`RemotePurchasesRepository.swift`** — skeleton only: `public final class`, conforms to the domain protocol, holds `private(set) var apiClient: APIClient` (not `private let`) so the value is accessible from split-file extensions in the same module
- **One `+<method>.swift` per operation** — each extension file contains exactly one method plus its private mapper extensions
- **DTO mapper methods are always `private extension` in the repository extension file** — never public methods on the DTO itself; this keeps DTOs pure and the mapping close to where it's used
- **Error mapping switch** — always handle every `APIClientError` case; map 401 → `.unauthorized`, 5xx → `.serverError`, `.requestTimeout` → `.requestTimeout`, `.noConnection` → `.noConnectivity`, everything else (including `.apiError` non-401, `.decodingError`, `.invalidURL`, `.unknownError`) → `.unexpectedError`

---

## Step 4 — Unit Tests

See `templates/tests.swift` for full boilerplate. Rules per test file:

### `<Feature>APIRequestTests.swift`

Test every property of every enum case:
- `method` — correct HTTP verb
- `endpoint` — exact path string
- `headers` — nil (or expected value)
- `queryParams` — correct key/value pairs AND correct count (prevents accidental extra params)
- `body` — nil for GET; correct keys for POST/PUT

### `Remote<Feature>Repository+<method>Tests.swift`

- **Success — single item**: verifies the page/model is returned and all mapped fields are correct
- **Success — multiple items**: verifies the full list is mapped (catches bugs in the `.map { }` that only affect first/last element)
- **Field mapping**: dedicated test that asserts every individual domain field, including type conversions (`String → Decimal`, `String → Date`, `String → StatusEnum`)
- **Optional field nil**: test that a `null` optional field in the response maps to `nil` in the domain model
- **Correct endpoint called**: assert `apiClient.requestHistory[0].endpoint` equals the expected path
- **All status enum values**: if the model has a status field, one test that maps all raw string values to the domain enum
- **Each error case**: one test per `APIClientError` mapping — 401, non-401 API error, server error, request timeout, no connection

### Factory functions

All factories must be **private instance methods inside the `@Suite` struct**, never free functions at module scope — required for Swift 6 actor isolation.

---

## Step 5 — Validate

**The task is not complete until `make qa-gates` passes green.** Run in order:

```bash
make generate   # register new files with Tuist — required after any file creation or deletion
make test       # unit tests only — fast feedback during development
make qa-gates   # full pipeline: build + lint + all tests + coverage — required before finishing
```

Fix every error and warning before considering the work done.
