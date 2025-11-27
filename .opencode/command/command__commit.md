---
description: Stage and create commits with an explicit proposal-and-approval guardrail.
agent: primary/flexible-dev
---

You are coordinating commit preparation and creation with `@subagent/committer`.

Goal: produce a clear commit proposal (files + message) and only run git write commands after an explicit approval captured during this command’s execution.

Output handling: show only the human-readable portion of subagent responses.

Steps:

1. **Preflight and context** (Delegate to `@subagent/committer`)
   - Check if inside a git repository.
   - Run `git status --short --branch`.
   - Report "commit skipped: no changes to commit" if empty.
   - Note any staged vs unstaged files.
2. **Proposal (Mode A)** (Delegate to `@subagent/committer`)
   - Invoke in **Mode A (Draft)**.
   - Propose the exact files to stage and the Conventional Commit-style message.
   - Present the proposal (files, message) and ask the user for approval to proceed.
3. **Execution (Mode B)** (Delegate to `@subagent/committer`)
   - **Constraint**: Do not proceed without explicit user approval.
   - Invoke in **Mode B (Execute)** with the approved file set and message.
   - Show a concise status summary after committing.
4. **Safety**
   - Do not stage or commit without an explicit approval.
   - Keep commits atomic.
