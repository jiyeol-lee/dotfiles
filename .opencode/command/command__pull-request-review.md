---
description: Review a GitHub pull request for regressions and quality opportunities.
---

You are coordinating two subagents:

- Regression persona: `@agent__github-pr-regression.md`
- Quality persona: `@agent__github-pr-quality.md`

Goal: mirror a full GitHub PR review (metadata gathering, repo inspection, regression + quality reporting) and stream the combined findings directly to the requester—no files.

Steps:

1. Treat `$1` as the comma-separated list of PR targets in the form `<owner>/<name>/<pr_number>`. If `$1` is empty or malformed, stop and request clarification.
2. Split `$1` by commas, trim whitespace, and launch a parallel job per PR. For each job:
   1. Parse `owner`, `name`, `pr_number` and set `REPO_FULL="${owner}/${name}"`.
   2. Create a disposable workspace (`./review-${owner}-${name}-${pr_number}-$(date +%s%N)`) and operate exclusively within it.
   3. **Collect PR metadata once** using the GraphQL query below so both agents share a consistent context. Substitute fallback text when fields are empty.
      ```
      gh api graphql -f query='
        query($owner: String!, $name: String!, $number: Int!) {
          repository(owner: $owner, name: $name) {
            pullRequest(number: $number) {
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
        }' -F owner="${owner}" -F name="${name}" -F number="${pr_number}"
      ```
   4. **Clone + checkout** the PR head inside `$workspace/repo`:
      - `gh repo clone "$REPO_FULL" repo -- --filter=blob:none`
      - `cd repo && git fetch origin pull/${pr_number}/head:pr-${pr_number}`
      - `git checkout pr-${pr_number}` and ensure `origin/<default-branch>` is fetched for diffs.
   5. Kick off two subtasks (parallel if resources allow):
      - **Regression task**: invoke `@agent__github-pr-regression.md` with `PR_NUMBER`, `REPO_FULL`, fetched metadata, and repo path. Direct it to inspect `git diff origin/<default-branch>...pr-${pr_number}` plus focus areas the user supplied.
      - **Quality task**: invoke `@agent__github-pr-quality.md` with the same context, asking for performance/best-practice opportunities.
        Capture each agent’s narrative (which already includes `No regressions found.` / `No quality improvements found.` when appropriate).
   6. Combine the outputs into a single markdown response with sections:
      - **Context** — include PR title, description, notable comments/reviews.
      - **Regression Risks** — regression agent output verbatim.
      - **Quality Opportunities** — quality agent output verbatim.
        Emit this response directly to STDOUT for the caller; do not create files.
   7. Clean up the workspace once you confirm both agent outputs are captured.
3. After all PR jobs finish, print a multi-PR summary referencing each `<owner>/<name> #<pr_number>` along with counts of regression risks and quality opportunities surfaced.
