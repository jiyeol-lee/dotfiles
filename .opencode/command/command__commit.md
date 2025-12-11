---
description: Create a git commit with staged changes
agent: primary/dev
---

You are coordinating git commit creation with `@subagent/commit`.

Goal: analyze changes, draft a commit message, confirm with user, then commit only after explicit approval.

Steps:

1. **Preflight** (Delegate to `@subagent/commit`)
   - Use `tool__git--status` to check repository state (staged, unstaged, untracked files).
   - If no changes exist, report and stop.
   - Summarize the changes (files modified, added, deleted).

2. **Draft (Mode A)** (Delegate to `@subagent/commit`)
   - Invoke in **Mode A (Draft)**.
   - **Analyze Changes**:
     - Use `tool__git--status` to identify staged files, then use `read` tool to examine specific file contents if needed.
     - Use `tool__git--retrieve-current-branch-diff` to view all changes compared to the base branch.
     - Use `tool__git--status` to identify unstaged files.
     - Categorize changes by type (feature, fix, refactor, docs, test, chore, etc.).
   - **Propose Staging**:
     - If there are unstaged changes, ask the user which files to stage.
     - List each file with its change type (modified, added, deleted).
     - Format:
       ```
       Files to stage:
       - [M] src/file1.ts (modified)
       - [A] src/file2.ts (new file)
       - [D] src/file3.ts (deleted)
       ```
   - **Draft Commit Message**:
     - Use Conventional Commits format: `<type>(<scope>): <description>`
     - Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build
     - Include body if changes are complex (wrapped at 72 chars).
     - Include footer for breaking changes or issue references.
     - Example:

       ```
       feat(auth): add OAuth2 login support

       - implement Google OAuth2 provider
       - add token refresh mechanism
       - update user session handling

       closes #123
       ```

   - Present the draft commit message and files to be staged.
   - **Ask explicitly**: "Do you approve this commit? (yes/no/edit)"

3. **Apply (Mode B)** (Delegate to `@subagent/commit`)
   - **Constraint**: Do not proceed without explicit user approval.
   - Invoke in **Mode B (Execute)**.
   - Use `tool__git--stage-files` with the list of files to stage.
   - Use `tool__git--commit` with the commit message (and optional body).
   - **Pre-commit Hook Handling**:
     - If commit fails due to pre-commit hooks that modify files:
       1. Stage the modified files with `tool__git--stage-files`
       2. Retry the commit **once** with `tool__git--commit`
       3. If still fails, report the hook error to user
   - **Push Option**: After successful commit, offer to push (requires explicit user approval).
   - Report the commit SHA and summary.

4. **Safety**
   - Never stage or commit without explicit user approval.

$ARGUMENTS
