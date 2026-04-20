---
name: "Create Issue"
description: "Create a structured GitHub issue (bug report, feature request, or task)"
mode: agent
tools: ["read_file"]
---

Before doing anything else, read the file `.claude/skills/create-issue/SKILL.md` in full and follow every instruction in it precisely. That file is the single source of truth for creating GitHub issues in this project.

Also read the relevant template in `.claude/skills/create-issue/templates/` (bug.md, feature.md, or task.md) based on the issue type requested.
