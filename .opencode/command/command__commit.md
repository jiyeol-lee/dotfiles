---
description: Create a git commit with staged changes
agent: primary/dev
---

You are coordinating git commit creation with `@subagent/commit`.

Goal: analyze changes, draft a commit message, confirm with user, then commit only after explicit approval.

Steps:

1. **Preflight** (Delegate to `@subagent/commit`)
   - Run `git status` to check repository state.
   - Identify staged and unstaged changes.
   - If no changes exist, report and stop.
   - Summarize the changes (files modified, added, deleted).

2. **Draft (Mode A)** (Delegate to `@subagent/commit`)
   - Invoke in **Mode A (Draft)**.
   - **Analyze Changes**:
     - Run `git diff --cached` for staged changes.
     - Run `git diff` for unstaged changes.
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

       - Implement Google OAuth2 provider
       - Add token refresh mechanism
       - Update user session handling

       Closes #123
       ```

   - Present the draft commit message and files to be staged.
   - **Ask explicitly**: "Do you approve this commit? (yes/no/edit)"

3. **Apply (Mode B)** (Delegate to `@subagent/commit`)
   - **Constraint**: Do not proceed without explicit user approval.
   - Invoke in **Mode B (Execute)**.
   - Stage the approved files: `git add <files>`.
   - Create the commit: `git commit -m "<message>"`.
   - Report the commit SHA and summary.

4. **Safety**
   - Never stage or commit without explicit user approval.
   - Never use `git commit -a` or `git add .` without user confirmation.
   - Never amend commits without explicit request.

$ARGUMENTS
