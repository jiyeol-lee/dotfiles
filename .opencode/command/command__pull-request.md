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
   - **If New PR**:
     - **Check for Template**: Try to read `.github/pull_request_template.md` or `pull_request_template.md`.
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
       - **Ask** the user explicitly: "Who should be the reviewer? Who should be the assignee?"
   - Present the draft (Title, Body), the list of collaborators, and wait for the user to provide the reviewer/assignee and approval.
3. **Publish (Mode B)** (Delegate to `@subagent/pull-request-handler`)
   - **Constraint**: Do not proceed without explicit user approval.
   - Invoke in **Mode B (Execute)**.
   - Push commits (if needed).
   - Create (`gh pr create`) or Update (`gh pr edit`) the PR.
     - Use the user-provided `--reviewer` and `--assignee` flags.
     - Do not add any other flags unless explicitly requested.
   - Report the final URL.
4. **Safety**
   - Never push or open a PR without explicit approval.
