---
name: "Analyze Bug"
description: "Trace and fix a reported bug: crashes, wrong state, UI issues, concurrency problems, test failures"
mode: agent
tools: ["read_file", "grep_search", "file_search", "list_dir", "run_in_terminal"]
---

Before doing anything else, read the file `.claude/skills/analyze-bug/SKILL.md` in full and follow every instruction in it precisely. That file is the single source of truth for how to debug issues in this project.

Also read `.claude/skills/analyze-bug/reference/categories.md` and `.claude/skills/analyze-bug/reference/pitfalls.md` — the skill workflow references them explicitly.
