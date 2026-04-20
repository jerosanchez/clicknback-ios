---
name: review-pr
description: Review current branch changes against main for architecture compliance, conventions, security, and test coverage. Runs QA gates and updates the linked GitHub issue checklist on success.
disable-model-invocation: true
context: fork
agent: Explore
allowed-tools: Bash(git diff *) Bash(git log *) Bash(git status) Bash(git branch *) Bash(git remote *) Bash(make lint) Bash(make build) Bash(make test) Bash(make test-all) Bash(make test-integration) Bash(make coverage *) Bash(make qa-gates) Bash(swiftlint *) Bash(swiftformat --lint *)
---

## Live branch context

**Changed files:**
```!
git diff main --stat 2>/dev/null || git diff HEAD~1 --stat
```

**Commits on this branch:**
```!
git log main..HEAD --oneline 2>/dev/null || git log HEAD~3..HEAD --oneline
```

**Full diff:**
```!
git diff main 2>/dev/null || git diff HEAD~1
```

---

## Workflow

1. Read each changed file; for context also read related files (tests, Container, protocol definitions)
2. Work through `reference/checklist.md` — cover Architecture, Naming, Swift 6, Testing, and Security
3. **Run QA gates** — execute `make qa-gates` and capture the result
4. **Output the structured review** (see format below)
5. **Update the linked GitHub issue** — if there is an open issue tracking this work (check `git log` for an issue reference, or ask the user), use the GitHub MCP tool to tick off the QA criteria in the Acceptance Criteria checklist:
   - If `make qa-gates` passed: mark `All tests pass (make qa-gates)` and `No new SwiftLint warnings introduced` as `[x]`
   - If it failed: leave them unchecked and include the failure output in the **❌ Must fix** section

## Allowed read-only CLI commands

The following commands are safe to run during a review — they never modify source files:

| Command | Purpose |
|---|---|
| `make build` | Verify the project compiles |
| `make test` | Unit tests only |
| `make test-integration` | Integration tests only |
| `make test-all` | Full test suite |
| `make coverage [MIN_COVERAGE=N]` | Coverage report |
| `make lint` | SwiftLint check |
| `make qa-gates` | Full pipeline (build + lint + all tests + coverage) |
| `swiftlint lint` | Direct SwiftLint invocation |
| `swiftformat --lint .` | Format check without writing |
| `git diff / log / status / branch / remote` | Branch and change inspection |

Never run any command that writes to source files (`swiftformat` without `--lint`, `make format`, `make generate`, etc.).

## Output format

**✅ Looks good** — what is well-implemented  
**⚠️ Suggestions** (non-blocking) — style or quality improvements  
**❌ Must fix** (blocking) — correctness, security, or convention violations before merging  
**🧪 QA gates** — result of `make qa-gates` (pass/fail + summary of any failures)
