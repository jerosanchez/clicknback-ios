---
name: analyze-performance
description: Profile and improve performance. Use when investigating dropped frames, UI freezes, slow screen loads, high memory usage, or redundant network calls.
disable-model-invocation: true
argument-hint: [area to profile, e.g. "wallet list scrolling" or "login screen load time"]
---

Performance area to analyze: $ARGUMENTS

## Workflow

1. **Identify category** — Match symptoms to a category in `reference/categories.md` to find the right Instrument
2. **Measure first** — Never optimize before profiling; open Xcode Instruments for the identified category
3. **Apply fixes** — Follow patterns in `reference/fixes.swift` for the identified category
4. **Re-measure** — Confirm improvement with the same Instrument before considering the task done
5. **Validate** — `make qa-gates` to confirm nothing regressed
6. **Document** — Leave a `// MARK: Performance:` comment explaining the optimization and measured gain
