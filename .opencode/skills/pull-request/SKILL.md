---
name: pull-request
description: Analyzes branch diffs, drafts PR titles and bodies following Conventional Commits, and creates or updates pull requests via GitHub CLI. Use when user asks to "create a PR", "open a pull request", "update PR description", "draft a PR", or "submit changes for review".
---

## Workflow

1. **Preflight**
   - Confirm git repo, branch, and commits exist
   - Ensure current branch is NOT `main` or `master` — abort if so
   - Check for unpushed commits
2. **Analyze**
   - Use `tool__git--retrieve-current-branch-diff` to analyze commits since diverging from target branch
   - Scan commit messages for issue references (e.g., `LINEAR-123`, `JIRA-456`, `#123`)
   - Check for PR template: try to read `.github/pull_request_template.md` or `pull_request_template.md`
3. **Draft**
   - **If existing PR**:
     - Fetch context (reviews, comments) using `tool__gh--retrieve-pull-request-info`
     - If a template was found, validate the existing body against it and draft updates conforming to the template
     - Draft content updates based on reviews/comments
   - **If new PR**:
     - If template found: fill it out with the summary of changes (do not change template structure or headers)
     - If no template: draft a standard title and body
     - Use `tool__gh--retrieve-repository-collaborators` to list available reviewers
     - Ask the user: "Who should be the reviewer?"
   - Present the draft (title, body) and wait for approval
4. **Publish** (only after explicit approval)
   - Push commits if needed: use `tool__git--push`
   - Use `tool__gh--create-pull-request` (new) or `tool__gh--edit-pull-request` (existing)
   - Use user-provided reviewers
   - Report the final PR URL

## PR Title Format

Follow Conventional Commits for the PR title:

| Prefix      | When to Use              |
| ----------- | ------------------------ |
| `feat:`     | New feature              |
| `fix:`      | Bug fix                  |
| `refactor:` | Code refactoring         |
| `docs:`     | Documentation only       |
| `chore:`    | Maintenance, deps, CI    |
| `test:`     | Adding or updating tests |

## PR Body Guidelines

- If a PR template exists, conform to its structure and headers exactly
- Summarize changes clearly — explain **why**, not just what or how
- Use markdown formatting for readability
- Include issue references if found in commits

## Example Output

For a branch with 3 commits adding a new caching layer:

**Title**: `feat: add Redis caching for user session lookups`

**Body**:

```markdown
## Summary

- Add Redis-based caching for user session lookups to reduce DB load
- Cache TTL is 15 minutes with automatic invalidation on session update
- Add `RedisCacheService` with connection pooling and retry logic
```

## Constraints

- NEVER create or update a PR without explicit user approval
- NEVER auto-select or recommend reviewers — list collaborators and let the user choose
- NEVER push without explicit approval
- NEVER force-push to main/master
