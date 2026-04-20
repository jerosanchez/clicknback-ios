---
name: analyze-bug
description: Trace and fix a reported bug. Use when debugging crashes, incorrect behavior, wrong state, UI not updating, concurrency issues, or test failures.
argument-hint: [bug description or symptoms]
---

Bug to investigate: $ARGUMENTS

## Workflow

1. **Classify** — Match symptoms to a category in `reference/categories.md` to determine the starting layer
2. **Trace** — Follow data flow top-down; read each layer before drawing conclusions:
   - **View** — Is `.onAppear {}` called? Is the correct ViewModel property bound?
   - **ViewModel** — `@MainActor` present? State set before AND after async call? `Task { [weak self] in ... }` used?
   - **UseCase** — All `Result` arms handled? Error mapped to the correct domain error type?
   - **Repository** — Correct endpoint, HTTP method, and body in `APIRequest`?
   - **APIClient / Storage** — Correct URL? Headers set? Decoder configured (date strategy, key decoding)?
3. **Check pitfalls** — Consult `reference/pitfalls.md` for common Swift 6, SwiftUI, decoding, and storage issues
4. **Fix** — Make the minimal change that resolves the bug; do not refactor unrelated code in the same change
5. **Regression test** — Add a `@Test` that would have caught this bug before it shipped; follow the `write-tests` skill
6. **Validate** — `make test` to confirm fix; `make qa-gates` to confirm nothing regressed
