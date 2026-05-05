---
name: build-data-layer
description: Scaffold the data layer (domain models, repository protocol, use case, error type, mock, preview data, unit tests) for a new feature. Use before building the infra or feature layers.
argument-hint: "[Feature name and domain description, or link to issue]"
---

Scaffold the data layer for: $ARGUMENTS

## What This Skill Produces

All files for `ClickNBack/Data/<Feature>/` plus corresponding mocks, preview data, and unit tests. The exact set of files depends on the feature — a feature with multiple operations needs one use case file per operation; a feature with a status field needs a separate `<Model>Status.swift`; paginated endpoints need `<Feature>sPage.swift` and `<Feature>sPagination.swift`. Plan the file list by reading the spec before writing any code.

---

## Step 1 — Domain (`ClickNBack/Data/<Feature>/`)

See `templates/domain.swift` for full boilerplate. Rules:

- One file per type — model, status enum, pagination, page, error, repository protocol, and each use case all get their own file
- Domain model is a **`struct`**, `Equatable`, no `Codable` — mapping from DTOs belongs in Infra
- **Monetary amounts → `Decimal`** — never `Double` (precision loss) or `String` (requires parsing at call sites)
- **Dates → `Date`** — ISO 8601 parsing is the DTO mapper's job; the domain model never holds raw strings for dates
- **Status enum** — include every value the API can return; omitting a case silently drops data
- **Error enum** — one case per distinct API error; always `Equatable`; standard set: `unauthorized`, `serverError`, `requestTimeout`, `noConnectivity`, `unexpectedError`
- **Repository protocol** — define `public typealias Fetch<Model>Result = Result<…, …>` at the top of the same file; one method per operation
- **Use case** — one `public execute` method per class; never add secondary getters or convenience accessors — extract them as separate use case classes
- **Pagination** — use the shared `Pagination` struct from `ClickNBack/Data/Shared/`; never create a feature-specific pagination type

---

## Step 2 — Mock and Preview Data

See `templates/mock.swift` for full boilerplate. Rules:

- Mock repository lives in **`ClickNBack/Support/Mocks/`** — never inline inside a test file
- Configurable via a handler closure (`fetch<Models>Handler`); default returns `.success(.mock)` so tests only override what they need
- Track call count with a `private(set) var …CallCount` property — required by delegation tests
- `<Model>+mock.swift` and `<Feature>sPage+mock.swift` go in **`ClickNBack/Support/Preview/Data/`**
- Array mock must have **≥3 items** with distinct values — catches bugs that only affect the first or last element
- Use **fixed UUIDs** (`550e8400-e29b-41d4-a716-44665544000x`) in mock data — deterministic, avoids masking bugs
- Use `Date(timeIntervalSince1970:)` for date literals — never string literals for `Date` fields
- Page mock sets `total` equal to the array count so pagination math is trivially verifiable

---

## Step 3 — Unit Tests (`ClickNBackTests/Unit/Data/<Feature>/`)

Read `.claude/skills/write-tests/SKILL.md` in full before writing any unit test.

See `templates/tests.swift` for full boilerplate. Rules:

- **Only write tests when there is logic to test.** A use case whose `execute` is a single-line passthrough to the repository has no product behaviour to verify — do not create a test file for it
- When logic is present (e.g. caching, filtering, transformation, authorization checks), write one test per behaviour and one test per error case

---

## Step 4 — Validate

**The task is not complete until `make qa-gates` passes green.** Run in order:

```bash
make generate   # register new files with Tuist — required after any file creation or deletion
make test       # unit tests only — fast feedback during development
make qa-gates   # full pipeline: build + lint + all tests + coverage — required before finishing
```

Fix every error and warning reported by `make qa-gates` before considering the work done. Do not stop at `make test` passing.
