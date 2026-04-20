---
name: create-issue
description: Create a GitHub issue for this project using the GitHub MCP tool.
disable-model-invocation: true
argument-hint: [brief description of the issue]
---

Create a GitHub issue for: $ARGUMENTS

## Workflow

1. **Get repo** — Run `git remote get-url origin`; extract `owner` and `repo` from the URL (e.g. `git@github.com:acme/clicknback-ios.git` → `acme` / `clicknback-ios`)
2. **Classify** — Determine type: Bug, Feature/Enhancement, or Task/Tech Debt; ask if unclear
3. **Fill template** — Use the matching body template: `templates/bug.md`, `templates/feature.md`, or `templates/task.md`
4. **Propose PR split** — Group the technical work into 2–3 PRs where each PR can be merged without breaking the app (see guidelines below)
5. **Create** — Call the GitHub MCP tool (`mcp__github__create_issue`) with `owner`, `repo`, `title`, `body`, and `labels`
6. **Confirm** — Share the created issue URL and number with the user

## PR Split Guidelines

Every issue must include a **Proposed PR Split** section. Group changes so that:

- Each PR compiles and does not break the running app when merged alone
- Additive-only changes (new protocols, use cases, models) ship first — they have zero risk
- New UI that is not yet reachable ships before the wiring that exposes it
- The PR that changes user-visible behaviour ships last
- Aim for 2–3 PRs; avoid splitting so finely that each PR is trivial

Label each PR with a one-line note explaining why it is safe to merge independently.
