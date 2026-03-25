---
name: review
description: Performs code review analysis across Quality, Regression, Documentation, and Performance focus areas with severity-classified findings. Use when user asks to "review code", "review this PR", "check code quality", "review changes", or "do a code review".
---

## Workflow

1. **Determine review target** from the task context:
   - Pull request: use `tool__gh--retrieve-pull-request-diff` to fetch the diff
   - Last N commits: use `tool__git--retrieve-latest-n-commits-diff` to get the diff
   - Branch changes: use `tool__git--retrieve-current-branch-diff` for current branch vs base
2. **Gather context** for each modified file:
   - Read the full file content (not just the diff) — surrounding code is essential for understanding impact
   - For PR reviews, use `tool__gh--retrieve-pull-request-info` to understand PR goals and existing feedback
3. **Review** using the assigned focus area and its reference checklist
4. **Classify findings** by severity (see below)
5. **Present report** grouped by file with actionable fix suggestions

## Focus Areas

One focus area is assigned per invocation. Read the reference checklist for your assigned focus area:

- **Quality**: Read `references/quality.md` — covers security, correctness, maintainability
- **Regression**: Read `references/regression.md` — covers breaking changes, API compatibility
- **Documentation**: Read `references/documentation.md` — covers code docs, changelogs, API specs
- **Performance**: Read `references/performance.md` — covers optimization, efficiency

## Severity Levels

| Level      | Icon | Criteria                         | Action     |
| ---------- | ---- | -------------------------------- | ---------- |
| Critical   | 🔴   | Security, data loss, outage risk | Must fix   |
| Warning    | 🟡   | Bugs, bad practices              | Should fix |
| Suggestion | 🔵   | Improvements                     | Consider   |

## Assessment Criteria

| Assessment           | When to Use                                  |
| -------------------- | -------------------------------------------- |
| **approve**          | No critical issues, code is ready            |
| **request_changes**  | Critical issues found that must be addressed |
| **needs_discussion** | Architectural concerns requiring team input  |

## Example Finding

A critical finding looks like this:

**🔴 Critical — File: `src/auth/login.ts` — Line 42**
- **Issue**: User-supplied `redirectUrl` is passed directly to `res.redirect()` without validation
- **Why**: Open redirect vulnerability — attacker can craft a URL that redirects users to a phishing site after login
- **Fix**: Validate `redirectUrl` against an allowlist of trusted domains before redirecting:
  ```ts
  const allowed = ['/dashboard', '/profile', '/settings'];
  const target = allowed.includes(redirectUrl) ? redirectUrl : '/dashboard';
  res.redirect(target);
  ```

## Report Format

Use the report format in `references/report-format.md` when generating the review report.

## Constraints

- NEVER approve code with unresolved critical issues
- NEVER ignore security-related findings regardless of focus area
- ALWAYS read the full file, not just the diff — context matters for correctness
- ALWAYS provide actionable fix suggestions, not just problem descriptions
