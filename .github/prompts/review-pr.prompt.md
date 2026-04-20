---
name: "Review PR"
description: "Review current branch changes for Clean Architecture compliance, Swift 6 correctness, and test coverage"
mode: agent
tools: ["read_file", "grep_search", "file_search", "list_dir", "run_in_terminal"]
---

Before doing anything else, read the file `.claude/skills/review-pr/SKILL.md` in full and follow every instruction in it precisely. That file is the single source of truth for pull request reviews in this project.

Also read `.claude/skills/review-pr/reference/checklist.md` — the review workflow uses it as its primary checklist.
