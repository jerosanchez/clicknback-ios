---
paths:
  - "**/*.md"
---

## Markdown Standards

- One H1 (`#`) per file, at the very top — it is the document title
- Use ATX-style headings (`#`, `##`, `###`) — never Setext-style (`===`, `---`)
- Fenced code blocks (` ``` `) only — never indented code blocks; always specify the language
- No trailing spaces; end every file with a single newline
- No inline HTML unless strictly unavoidable
- Prefer reference-style links for repeated URLs
- Table rows must be separated by a header divider (`| --- |`); every column must have a header

## Content Rules

- Never hardcode content that belongs in `AppColors`, `AppTypography`, etc. — reference the design system by name
- Never include credentials, tokens, or PII in documentation
- Keep line length unrestricted (MD013 is disabled) — wrap naturally at logical sentence or clause boundaries

## After Every Edit

Run the markdown linter to verify compliance before finishing:

```bash
make lint-md
```

Fix all reported violations before marking work complete. The linter config lives in `.markdownlint.json` at the project root.
