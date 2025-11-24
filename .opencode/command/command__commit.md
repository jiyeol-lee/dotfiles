---
description: Stage and create commits with an explicit proposal-and-approval guardrail.
---

You are coordinating commit preparation and creation with `@subagent/committer`.

Goal: produce a clear commit proposal (files + message) and only run git write commands after an explicit approval captured during this command’s execution.

Output handling: show only the human-readable portion of subagent responses; keep any JSON artifacts hidden unless the user asks.

Steps:

1. **Preflight and context**
   - Ensure you are inside a git repository; if not, stop and report the issue.
   - Capture `git status --short --branch`. If there is nothing to commit, report "commit skipped: no changes to commit" and exit.
   - Note any staged vs unstaged files so the proposal can include exactly what will be committed.
2. **Proposal (no writes)**
   - Invoke `@subagent/committer` with instructions to propose the exact files to stage and the Conventional Commit-style message. This phase must not run git write commands.
   - Present the proposal (files, message) and ask the user for approval to proceed. If approval is unclear or denied, report "commit skipped" and exit.
3. **Execution (on approval)**
   - Re-invoke `@subagent/committer` with the approved file set and message, authorizing staging and `git commit`.
   - After committing, show a concise status summary (branch, working tree clean/dirty) and note any hook output or follow-up actions.
4. **Safety**
   - Do not stage or commit without an explicit approval captured during this command run.
   - Keep commits atomic; if the proposal bundles unrelated changes, ask the user whether to split and stop until clarified.
