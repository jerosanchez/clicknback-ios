---
name: write-docs
description: Write DocC documentation for Swift types. Use when asked to document a protocol, use case, repository, view model, model, or any public API.
argument-hint: [type or file to document]
---

Document: $ARGUMENTS

## Standards

- Summary: one clear sentence after `///`; no "This class/struct/function" preamble
- Parameters: `/// - Parameter name:` for every non-obvious parameter
- Returns: `/// - Returns:` describing both success and failure values
- Example: `/// - Example:` block for non-trivial or non-obvious APIs
- Never restate the type name or parameter type (already visible in the signature)
- Don't document `private` / `internal` members unless logic is genuinely non-obvious
- Run `make build` after writing — DocC warnings appear as build warnings

## By component type

- **Protocol** — describe the contract, intended usage scope, and thread safety; document each method including error cases and side effects
- **Use Case** — what business rule it orchestrates; what it persists or emits as a side effect
- **Repository (protocol)** — the storage/network abstraction boundary; who should call it
- **ViewModel** — what screen it drives; list `State` cases and the transitions between them
- **Model** — semantic meaning of each property, not its type; note invariants (e.g. `id` is never empty)
- **Error enum** — document each case: what condition produces it, what the caller should do
- **Container** — why it exists and what dependencies it wires

See `examples/by-component-type.swift` for DocC templates per component type.
