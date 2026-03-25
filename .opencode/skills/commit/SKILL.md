---
name: commit
description: Analyzes repository state, proposes commit messages following Conventional Commits, and applies commits after user approval. Use when asked to "commit", "commit changes", "save my work", "create a commit", or "stage and commit".
---

## Workflow

1. **Preflight**
   - Use `tool__git--status` to check repository state (staged, unstaged, untracked files)
   - If no changes exist, report and stop
2. **Analyze changes**
   - Use `tool__git--retrieve-current-branch-diff` to view all changes compared to the base branch
   - Categorize changes by type (feature, fix, refactor, docs, test, chore, etc.)
3. **Propose staging**
   - If there are unstaged changes, ask the user which files to stage
   - List each file with its change type:
     ```
     Files to stage:
     - [M] src/file1.ts (modified)
     - [A] src/file2.ts (new file)
     - [D] src/file3.ts (deleted)
     ```
4. **Draft commit message**
   - Use Conventional Commits format (see below)
   - Include body if changes are complex (wrapped at 72 chars)
   - Include footer for breaking changes or issue references
   - Always use lowercase unless proper nouns
5. **Ask for approval**: Present the draft and ask "Do you approve this commit? (yes/no/edit)"
6. **Commit** (only after explicit approval)
   - Use `tool__git--stage-files` with the list of files
   - Use `tool__git--commit` with the commit message
   - Handle pre-commit hooks (see below)
   - After successful commit, offer to push (requires explicit approval)
   - Report the commit SHA and summary

## Conventional Commits Format

```
<type>(<scope>): <description>

[optional body wrapped at 72 chars]

[optional footer(s)]
```

Use standard types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`.

**Breaking changes** — append `!` after type/scope:
```
feat(api)!: change response format from XML to JSON

BREAKING CHANGE: API responses are now JSON. Clients using XML
parsing must migrate to JSON parsing.
```

## Example: Full Commit Workflow

```
> tool__git--status
  Staged:     (none)
  Unstaged:   src/auth.ts (modified), src/auth.test.ts (modified)
  Untracked:  src/middleware/rateLimit.ts

> tool__git--retrieve-current-branch-diff
  src/auth.ts: Added JWT token refresh logic
  src/auth.test.ts: Added tests for token refresh
  src/middleware/rateLimit.ts: New rate limiting middleware

> Propose staging:
  Files to stage:
  - [M] src/auth.ts (modified)
  - [M] src/auth.test.ts (modified)
  - [A] src/middleware/rateLimit.ts (new file)

  Suggested split into 2 commits:
  1. feat(auth): add JWT token refresh logic
     - src/auth.ts, src/auth.test.ts
  2. feat(middleware): add rate limiting middleware
     - src/middleware/rateLimit.ts

  Do you approve this commit plan? (yes/no/edit)

> User: yes

> tool__git--stage-files ["src/auth.ts", "src/auth.test.ts"]
> tool__git--commit "feat(auth): add JWT token refresh logic"
  ✓ Commit abc1234

> tool__git--stage-files ["src/middleware/rateLimit.ts"]
> tool__git--commit "feat(middleware): add rate limiting middleware"
  ✓ Commit def5678

  Would you like to push? (yes/no)
```

## Pre-Commit Hook Handling

This is a common failure mode — follow these steps exactly:

1. **First attempt**: Make initial commit
2. **If failed with modified files** (hook auto-formatted code): Stage the modified files and retry **once**
3. **If retry still fails**: Report the hook error to user — do NOT keep retrying

## Constraints

- NEVER create empty commits
- NEVER commit without explicit user approval
- NEVER push without explicit user approval
- NEVER use `--no-verify` to skip pre-commit hooks
- NEVER amend commits that have been pushed to remote
