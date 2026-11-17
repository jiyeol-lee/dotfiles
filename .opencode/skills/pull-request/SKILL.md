---
name: pull-request
description: Opens or updates a draft pull request whose description explains the change by behavior. Use when a change is ready to ship as a PR, such as "open a PR", "create a pull request", or "update the PR", and when a playbook step names it.
---

# Pull request

The PR tells a reviewer what changed in behavior and why, in under a minute.

## Steps

1. **Check the branch.** It is not `main` or `master`.
2. **Commit what is left.** This is a fallback: each playbook commits its own work in its own step. If files you changed for this task are still uncommitted, commit them. Leave edits you did not make out of the commit.
3. **Push** with `git push -u origin HEAD` when the branch is missing from the remote or behind it. A request to open the PR covers this push, so do not ask for it separately.
4. **Summarize the change by behavior.** Read `git diff <base>...HEAD`, then describe what changed for users and callers, and why. Do not describe it file by file.
5. **Follow the template** at `.github/pull_request_template.md` or `pull_request_template.md` when one exists, keeping its structure and headings. Without one, use `## Why`, `## What changed`, and `## Verification`.
6. **Open it as a draft** with `gh pr create --draft --assignee @me`, titled in Conventional Commits form: `type(scope): subject`. Add `--base <branch>` only when the user or the calling playbook names a base branch. Otherwise leave the base to the repository default. Update an existing PR with `gh pr edit` instead.

## Output

PR link that you created or updated.
