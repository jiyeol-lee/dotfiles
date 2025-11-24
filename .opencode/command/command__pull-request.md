---
description: Create or update a pull request with explicit approval and clear publish checks.
---

You are coordinating pull request drafting and publication with `@subagent/pull-request-handler`.

Goal: draft the PR content, confirm publish readiness, then push and open/update the PR only after explicit approval gathered within this command.

Output handling: show only the human-readable portion of subagent responses; keep any JSON artifacts hidden unless the user asks.

Steps:

1. **Preflight**
   - Confirm you are inside a git repository on the intended branch and that commits exist to publish; if the working tree is dirty, halt and ask the user to clean up before proceeding.
   - Summarize branch, latest commit(s), and recent test results if available. If tests are missing or failing, flag this and ask whether to proceed or stop.
2. **Draft (no remote writes)**
   - Invoke `@subagent/pull-request-handler` to draft the title/body using repository templates when present and to summarize risks, testing, and linked tickets. This step must not push or open a PR.
   - Check if a PR already exists for the current branch using `gh pr view`. If no PR exists, run the following command to fetch and display reviewer options from the repository's collaborators:
     ```
     gh api graphql --paginate \
         -f owner=$(gh repo view --json owner -q .owner.login) \
         -f repo=$(gh repo view --json name -q .name) \
         -f query='
         query($owner:String!, $repo:String!, $cursor:String) {
           repository(owner:$owner, name:$repo) {
             collaborators(first:100, after:$cursor) {
               nodes { login name }
               pageInfo { hasNextPage endCursor }
             }
           }
         }' \
         -q '[.data.repository.collaborators.nodes[] | {login, name}]'
     ```
     Then ask the user who they want to ask for review.
   - If a PR already exists, check if reviewers are assigned using `gh pr view --json reviewRequests`. Ask for reviewer selection only if no reviewers are assigned now (and fetch collaborators if needed for options).
   - Map selected reviewers to their GitHub usernames from the repo's collaborators (do not search globally). If a requested reviewer is not a collaborator, prompt for another name.
   - Present the draft along with any readiness concerns and ask for approval to publish. If approval is unclear or denied, report "PR skipped" and exit.
3. **Publish (on approval)**
   - Re-invoke `@subagent/pull-request-handler` with approval to push commits (if needed) and create/update the PR. Capture the resulting URL and any required labels/reviewers.
   - After the subagent returns a PR URL, use `gh pr edit` to set the assignee to `@me` and add reviewer(s) using the resolved collaborator usernames. If no PR exists yet, create with `gh pr create`, then apply the assignments via `gh pr edit`. On any `gh` failure (missing permissions, user not found, etc.), abort publishing and report the reason to STDOUT. Report the PR URL and any follow-up actions (labels, reviewers, release notes).
4. **Safety**
   - Never push or open a PR without explicit approval captured during this command run.
   - If commits were skipped or the branch is not publish-ready, stop and surface that state rather than attempting to push.
