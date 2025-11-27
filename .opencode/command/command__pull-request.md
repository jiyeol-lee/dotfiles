---
description: Create or update a pull request with explicit approval.
agent: primary/flexible-dev
---

You are coordinating pull request drafting and publication with `@subagent/pull-request-handler`.

Goal: draft the PR content, confirm readiness, then push and open/update the PR only after explicit approval.

Steps:

1. **Preflight** (Delegate to `@subagent/pull-request-handler`)
   - Confirm git repo, branch, and commits exist.
   - Summarize recent test results (delegate to `@subagent/tester` if needed).
2. **Draft (Mode A)** (Delegate to `@subagent/pull-request-handler`)
   - Invoke in **Mode A (Draft)**.
   - Check if PR exists (`gh pr view`).
   - If new, list collaborators (`gh api graphql ...`) and ask for reviewers.
   - Draft title, body, labels, and reviewers.
   - Present the draft and ask for approval to publish.
3. **Publish (Mode B)** (Delegate to `@subagent/pull-request-handler`)
   - **Constraint**: Do not proceed without explicit user approval.
   - Invoke in **Mode B (Execute)**.
   - Push commits (if needed).
   - Create (`gh pr create`) or Update (`gh pr edit`) the PR.
   - Report the final URL.
4. **Safety**
   - Never push or open a PR without explicit approval.
