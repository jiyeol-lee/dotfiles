---
description: Create or update a pull request with explicit approval.
agent: primary/dev
---

You are coordinating pull request drafting and publication with `@subagent/pull-request`.

Goal: draft the PR content, confirm readiness, then push and open/update the PR only after explicit approval.

Steps:

1. **Preflight** (Delegate to `@subagent/pull-request`)
   - Confirm git repo, branch, and commits exist.
   - Ensure current branch is not `main` or `master`.
   - Check if there are unpushed commits.
   - Summarize recent test results (delegate to `@subagent/qa` if needed).

2. **Draft (Mode A)** (Delegate to `@subagent/pull-request`)
   - Invoke in **Mode A (Draft)**.
   - Use `tool__git--retrieve-current-branch-diff` to analyze commits since diverging from target branch.
   - **Extract Linked Issues**: Scan commit messages for issue references (e.g., `LINEAR-123`, `JIRA-456`, `#123`).
   - **Check for Template**: Try to read `.github/pull_request_template.md` or `pull_request_template.md`.
     - If found, store the template structure (headers, sections) for use in drafting or validation.
     - If not found, note that a standard format will be used.
   - **If Existing PR**:
     - Fetch context (reviews, comments, review comments) using `tool__gh--retrieve-pull-request-info` tool.
     - **Template Validation** (if template was found):
       - Compare the existing PR body against the template structure.
       - Verify all required sections/headers from the template are present.
       - If sections are missing or structure deviates:
         - **Draft an updated body** that conforms to the template while preserving existing content.
         - Clearly indicate which sections were added or restructured.
       - If structure is valid: Note that no structural changes are needed.
     - **Draft Updates**: Based on reviews/comments, draft any content updates while maintaining template conformance.

   - **If New PR**:
     - **Draft Content**:
       - If template found: Fill it out with the summary of changes. **Do NOT** change the template structure or headers.
       - If no template: Draft a standard Title and Body.
     - **List Collaborators**: Use `tool__gh--retrieve-repository-collaborators` to list available reviewers.
     - **Constraint**:
       - **Do NOT** recommend or select reviewers automatically.
       - **List** the collaborators to let the user choose.
       - **Ask** the user explicitly: "Who should be the reviewer?"
   - Present the draft (Title, Body), the list of collaborators (for new PRs), and wait for the user to provide approval (and reviewer for new PRs).

3. **Publish (Mode B)** (Delegate to `@subagent/pull-request`)
   - **Constraint**: Do not proceed without explicit user approval.
   - Invoke in **Mode B (Execute)**.
   - Push commits (if needed): Use `tool__git--push` to push the branch to remote.
   - Use `tool__gh--create-pull-request` to create the PR or `tool__gh--edit-pull-request` to update an existing PR.
   - Use the user-provided reviewers.
   - Report the final URL.

4. **Safety**
   - Never push or open a PR without explicit approval.
   - Never auto-select reviewers.

$ARGUMENTS
