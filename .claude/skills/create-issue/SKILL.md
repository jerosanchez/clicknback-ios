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
4. **Create** — Call the GitHub MCP tool (`mcp__github__create_issue`) with `owner`, `repo`, `title`, `body`, and `labels`
5. **Confirm** — Share the created issue URL and number with the user
