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
   - Check if PR exists (`gh pr view`).
   - **Check for Template**: Try to read `.github/pull_request_template.md` or `pull_request_template.md`.
     - If found, store the template structure (headers, sections) for use in drafting or validation.
     - If not found, note that a standard format will be used.
   - **If Existing PR**:
     - Fetch context (reviews, comments, review comments) using:

     ```bash
     gh api graphql -f query='
       query($owner: String!, $name: String!, $number: Int!) {
         repository(owner: $owner, name: $name) {
           pullRequest(number: $number) {
             state
             title
             body
             comments(first: 100) { nodes { author { login } body } }
             reviews(first: 30) { nodes { author { login } body state } }
             reviewThreads(first: 100) {
               nodes {
                 comments(first: 20) { nodes { author { login } body path } }
               }
             }
           }
         }
       }' -F owner="$(gh repo view --json owner -q .owner.login)" -F name="$(gh repo view --json name -q .name)" -F number="$(gh pr view --json number -q .number)"
     ```

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
     - **List Collaborators**: Run the following to see available reviewers:
       ```bash
       gh api graphql -f query='
       query($owner: String!, $name: String!) {
         repository(owner: $owner, name: $name) {
           collaborators(first: 100) {
             edges {
               node {
                 login
                 name
               }
             }
           }
         }
       }' -F owner="$(gh repo view --json owner -q .owner.login)" -F name="$(gh repo view --json name -q .name)" | jq '[.data.repository.collaborators.edges[].node | {login, name}]'
       ```
     - **Constraint**:
       - **Do NOT** recommend or select reviewers automatically.
       - **List** the collaborators to let the user choose.
       - **Ask** the user explicitly: "Who should be the reviewer?"
   - Present the draft (Title, Body), the list of collaborators (for new PRs), and wait for the user to provide approval (and reviewer for new PRs).

3. **Publish (Mode B)** (Delegate to `@subagent/pull-request`)
   - **Constraint**: Do not proceed without explicit user approval.
   - Invoke in **Mode B (Execute)**.
   - Push commits (if needed): `git push origin <branch>`.
   - Create (`gh pr create`) or Update (`gh pr edit`) the PR.
     - Always use `--assignee @me`. Use the user-provided `--reviewer` flag.
     - Do not add any other flags unless explicitly requested.
   - Report the final URL.

4. **Safety**
   - Never push or open a PR without explicit approval.
   - Never auto-select reviewers. Always assign to `@me`.
   - Never modify PR labels or milestones without explicit request.

$ARGUMENTS
