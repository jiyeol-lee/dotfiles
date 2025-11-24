---
description: Review a GitHub pull request for regressions, quality opportunities, and documentation accuracy.
---

You orchestrate three subagents and must delegate every operational step: `@subagent/generalist` handles input parsing, metadata/ticket context, and markdown rendering; `@subagent/developer` owns workspace creation, cloning, fetch/checkout, and teardown; `@subagent/reviewer` runs the three required focus areas (Regression Risk, Quality Opportunities, Documentation Accuracy). Do not perform these steps yourself—always hand them off.

Goal: mirror a full GitHub PR review (metadata gathering, linked ticket context, repo inspection, regression + quality + documentation accuracy reporting) and stream the combined findings directly to the requester—no files.

Output handling: subagent replies are JSON; do not request a schema. Render with the markdown template below (fill "N/A" when empty):

```markdown
## Review Report for <owner>/<name> #<pr_number>

### Context

- **Title:** <title>
- **Description:** <body summary>
- **Linked Ticket:** <linear/atlassian summary or "No linked ticket found">
- **Latest Decision:** <direction>

### Regression Risks

- **Finding:** <severity> — <title> (<location>)
  - **Details:** <details>
  - **Suggestion:** <suggestion>
  - **Tests:** <tests or "N/A">
- **Risks noted:** <risks array or "N/A">
- **Tests Summary:** passed <passed> · missing <missing> · failing <failing>
- **Follow-ups:** <follow_ups or "N/A">

### Quality Opportunities

- **Finding:** <severity> — <title> (<location>)
  - **Details:** <details>
  - **Suggestion:** <suggestion>
  - **Tests:** <tests or "N/A">
- **Risks noted:** <risks array or "N/A">
- **Tests Summary:** passed <passed> · missing <missing> · failing <failing>
- **Follow-ups:** <follow_ups or "N/A">

### Documentation Accuracy

- **Finding:** <severity> — <title> (<location>)
  - **Details:** <details>
  - **Suggestion:** <suggestion>
  - **Tests:** <tests or "N/A">
- **Risks noted:** <risks array or "N/A">
- **Tests Summary:** passed <passed> · missing <missing> · failing <failing>
- **Follow-ups:** <follow_ups or "N/A">

### Summary

- **Key takeaways:** <concise summary across all three passes>
```

Safeguards:

- Never write files outside the checked-out repo; all output should stream to STDOUT for a local, read-only review.
- Only perform read-only network calls; never push, update tickets, or trigger remote side effects.

Steps:

1. **Collect targets** (delegate to `@subagent/generalist`)
   - `$1` is the comma-separated list of PRs in the form `<owner>/<name>/<pr_number>`. If empty or malformed, request clarification.
   - Split by comma, trim whitespace, and launch a parallel job per PR.
2. **For each PR** (coordinate `@subagent/generalist` for parsing/context and `@subagent/developer` for workspace/git operations)
   1. Parse `owner`, `name`, `pr_number`; set `REPO_FULL="${owner}/${name}"`. (`@subagent/generalist`)
   2. Have `@subagent/developer` create a disposable workspace `./review-${owner}-${name}-${pr_number}-$(date +%s%N)` and work only inside it.
   3. **Collect PR metadata once** (delegate to `@subagent/generalist`) so all review passes share the same context; substitute fallback text when fields are empty:
      ```
      gh api graphql -f query='
        query($owner: String!, $name: String!, $number: Int!) {
          repository(owner: $owner, name: $name) {
            pullRequest(number: $number) {
              state
              reviewDecision
              mergeStateStatus
              baseRefName
              headRefName
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
   4. **Enrich with linked ticket context via MCP** (delegate to `@subagent/generalist`):
      - Derive candidate ticket IDs from branch name, PR title/body, and explicit links in comments.
      - If there is any link to `linear` or `atlassian`, use `mcp__linear` or `mcp__atlassian` to query it for the most relevant ticket to pull description, status, latest decision, and acceptance criteria. Note when none is available or found.
      - Summarize the latest decision/direction so reviewers know expectations before inspecting code.
   5. **Clone + checkout** (delegate to `@subagent/developer`):
      - `gh repo clone "$REPO_FULL" "$workspace" -- --filter=blob:none`
      - `cd "$workspace" && git fetch origin pull/${pr_number}/head:pr-${pr_number}`
      - `git checkout pr-${pr_number}` and ensure `origin/<default-branch>` is fetched for diffs.
   6. Have `@subagent/developer` capture a shared reviewer payload immediately after checkout so every reviewer invocation reuses the same data:
      - `git diff origin/<default-branch>...pr-${pr_number}` (full patch)
      - `git diff --stat origin/<default-branch>...pr-${pr_number}`
      - `git diff --name-only origin/<default-branch>...pr-${pr_number}`
      - Summarize the latest available test status/logs (include command, timestamp, and pass/fail notes).
        Share this payload with all reviewer calls to avoid redundant git work.
3. **Launch reviews** (delegate to `@subagent/reviewer`) with shared context (PR metadata, ticket details, latest decision, repo path, default branch, PR number) **and the shared reviewer payload from Step 2.6**:
   - Run **three** reviewer calls in parallel (mandatory) to satisfy the `.opencode/AGENTS.md` focus areas—Regression Risk, Quality Opportunities, and Documentation Accuracy—explicitly referencing the shared payload so no pass recomputes diffs or test summaries. Coordinate them so they each know the others are running concurrently and avoid duplicate findings.
   - Regression Risk review: evaluate regressions, functional safety, and downstream impact using the shared diff outputs/test summary plus any user-supplied focus areas. Inspect nearby code when needed.
   - Quality Opportunities review: assess performance, maintainability, usability, test completeness, and related impacts by reusing the shared payload alongside the common context; check neighboring patterns for alignment.
   - Documentation Accuracy review: ensure README/CHANGELOG/inline comments stay correct relative to the proposed changes by leveraging the shared payload to spot doc drift, call out missing updates, and flag misleading docs or config drift stemming from the PR.
     Consume the JSON outputs from the three passes and render them into the markdown template before streaming.

4. **Compose per-PR output** (delegate to `@subagent/generalist`) as markdown to STDOUT:
   - **Context** — PR title, description, notable comments/reviews, linked ticket summary (or “No linked ticket found”), latest decision/direction.
   - **Regression Risks** — items rendered from the regression-risk JSON (`findings`, `risks`, `tests_summary`, `follow_ups`).
   - **Quality Opportunities** — items rendered from the quality-review JSON (`findings`, `risks`, `tests_summary`, `follow_ups`).
   - **Documentation Accuracy** — items rendered from the documentation-review JSON (`findings`, `risks`, `tests_summary`, `follow_ups`).
     Only mark items as blockers when clearly actionable and justified (reproducible failures, correctness breaks, policy violations); otherwise mark non-blocking with rationale.

5. **After all PR jobs finish** (coordinate `@subagent/developer` for cleanup and `@subagent/generalist` for reporting)
   - `@subagent/developer` tears down all workspaces created for the reviews.
   - `@subagent/generalist` prints a multi-PR summary.
