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
2. **Resolve command prefix** based on detected package manager (see Command Resolution below)
3. **Run checks in order**: lint → type-check → format → test
4. **Collect all results** before reporting (do not stop at first failure)
5. **Report** all findings to orchestrator with file paths and error messages

Read `references/commands.md` **when** you need language-specific validation commands for a language not listed in the auto-fix policy below.

## Tool Detection

Detect the actual tooling from project files to determine which commands to use:

### JavaScript/TypeScript

Read `package.json` to detect package manager:

1. Check for `packageManager` field (e.g., `"pnpm@8.0.0"`)
2. Check for lock files:
   - `pnpm-lock.yaml` → use `pnpm`
   - `yarn.lock` → use `yarn`
   - `package-lock.json` → use `npm`
3. Fall back to `npm` if none detected

### Python

Read `pyproject.toml` to detect tooling:

1. Check for `[tool.poetry]` section → use `poetry run` prefix
2. Check for `requirements.txt` → use default `pip` commands
3. Check for `Pipfile` → use `pipenv run`
4. Fall back to default `python`/`python3` and `pip` commands

### Go

Use standard `go` commands (e.g., `go fmt`, `go test`).

## Command Resolution

Resolve the correct command prefix based on detected package manager:

| Detection Method                                 | Command Prefix            |
| ------------------------------------------------ | ------------------------- |
| `packageManager` field in package.json with pnpm | `pnpm`                    |
| `pnpm-lock.yaml` exists                          | `pnpm`                    |
| `yarn.lock` exists                               | `yarn`                    |
| `package-lock.json` exists                       | `npm`                     |
| None detected                                    | `npm` (fallback)          |
| Python with poetry                               | `poetry run`              |
| Python without poetry                            | `python`/`python3`, `pip` |
| Go                                               | `go` (standard)           |

**Important**: Always resolve commands based on detected project tooling, never assume or hardcode `npx`, `npm`, `pip`, etc.

## Example: Dynamic Tool Detection

```
> Project detected: JavaScript/TypeScript

Step 1 — Detect package manager:
  $ cat package.json | grep packageManager
  "packageManager": "pnpm@8.0.0"
  → Using pnpm as command prefix

Step 2 — Lint:
  $ pnpm eslint src/
  ✗ 2 errors found
    src/api.ts:14 — no-unused-vars
    src/utils.ts:8 — @typescript-eslint/no-explicit-any

Step 3 — Type check:
  $ pnpm tsc --noEmit
  ✗ 1 error found
    src/api.ts:22 — Type 'string' is not assignable to type 'number'

Step 4 — Format (auto-fix allowed):
  $ pnpm prettier --write "src/**/*.ts"
  ✓ 3 files reformatted

Step 5 — Tests:
  $ pnpm test
  ✓ 42 tests passed, 0 failed

Report to orchestrator:
  - 2 lint errors (for code agent to fix)
  - 1 type error (for code agent to fix)
  - 3 files auto-formatted
  - All tests passing
```

## Auto-fix Policy

**Formatters ONLY — these are allowed to auto-fix:**

| Language      | Commands                                            |
| ------------- | --------------------------------------------------- |
| JavaScript/TS | `<prefix> prettier --write`, `<prefix> prettier -w` |
| Go            | `go fmt`, `gofmt`, `gofmt -w`                       |
| Python        | `<prefix> black`, `<prefix> ruff format`            |

**Note**: Replace `<prefix>` with the resolved command prefix based on detected package manager (e.g., `pnpm prettier --write` if pnpm is detected).

## Constraints (Never Allowed)

- Running lint auto-fix commands (`eslint --fix`, `ruff --fix`)
- Running E2E tests (playwright, cypress)
- Modifying source code to fix errors (report them instead)
- Hardcoding or assuming specific package managers (always detect from project files)

## Report to Orchestrator

- All lint errors with file paths and line numbers (for code agent to fix)
- All type errors with file paths and line numbers (for code agent to fix)
- Test failures with names and error output (for code agent to fix)
- Files that were auto-formatted (informational)
