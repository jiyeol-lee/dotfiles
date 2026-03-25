---
name: check
description: Verifies code quality through linting, type-checking, formatting, and testing. Use when asked to "run checks", "validate code", "lint this", "check for errors", "run tests", or "verify code quality" before or after changes.
---

## Quick Start

- Runs linters and reports violations (does NOT auto-fix lint errors)
- Runs type checkers and reports errors
- Auto-fixes formatting only (prettier, black, go fmt, ruff format)
- Runs tests (unit + integration)
- Philosophy: **Verify and report. Only auto-fix formatting.** All other issues go to orchestrator.

## Workflow

1. **Detect language/toolchain** from project files (package.json, go.mod, pyproject.toml, etc.)
2. **Run checks in order**: lint → type-check → format → test
3. **Collect all results** before reporting (do not stop at first failure)
4. **Report** all findings to orchestrator with file paths and error messages

Read `references/commands.md` **when** you need language-specific validation commands for a language not listed in the auto-fix policy below.

## Example: TypeScript Project Check

```
> Project detected: TypeScript (package.json with typescript dependency)

Step 1 — Lint:
  $ npx eslint src/
  ✗ 2 errors found
    src/api.ts:14 — no-unused-vars
    src/utils.ts:8 — @typescript-eslint/no-explicit-any

Step 2 — Type check:
  $ npx tsc --noEmit
  ✗ 1 error found
    src/api.ts:22 — Type 'string' is not assignable to type 'number'

Step 3 — Format (auto-fix allowed):
  $ npx prettier --write "src/**/*.ts"
  ✓ 3 files reformatted

Step 4 — Tests:
  $ npm test
  ✓ 42 tests passed, 0 failed

Report to orchestrator:
  - 2 lint errors (for code agent to fix)
  - 1 type error (for code agent to fix)
  - 3 files auto-formatted
  - All tests passing
```

## Auto-fix Policy

**Formatters ONLY — these are allowed to auto-fix:**

| Language      | Commands                          |
| ------------- | --------------------------------- |
| JavaScript/TS | `prettier --write`, `prettier -w` |
| Go            | `go fmt`, `gofmt`, `gofmt -w`     |
| Python        | `black`, `ruff format`            |

## Constraints (Never Allowed)

- Running lint auto-fix commands (`eslint --fix`, `ruff --fix`)
- Running E2E tests (playwright, cypress)
- Modifying source code to fix errors (report them instead)

## Report to Orchestrator

- All lint errors with file paths and line numbers (for code agent to fix)
- All type errors with file paths and line numbers (for code agent to fix)
- Test failures with names and error output (for code agent to fix)
- Files that were auto-formatted (informational)
