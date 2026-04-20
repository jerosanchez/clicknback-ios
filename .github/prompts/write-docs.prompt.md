---
name: "Write Docs"
description: "Write documentation for this project: DocC for Swift types (protocols, use cases, repositories, view models) or Markdown files (README, CONTRIBUTING, guides)"
mode: agent
tools: ["read_file", "grep_search", "file_search", "list_dir", "run_in_terminal"]
---

Identify what kind of documentation is being written, then load the corresponding rules:

**For Swift DocC documentation** (documenting a Swift type, protocol, use case, repository, view model, or public API):

1. Read `.claude/skills/write-docs/SKILL.md` in full — single source of truth for DocC standards.
2. Read `.claude/skills/write-docs/examples/by-component-type.swift` for canonical examples.

**For Markdown documentation** (creating or editing any `.md` file):

1. Read `.claude/rules/markdown.md` in full — single source of truth for Markdown standards.
2. After every edit, run `make lint-md` and fix all reported violations before finishing.
