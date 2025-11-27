---
description: Review a GitHub pull request for regressions, quality, and docs.
agent: primary/flexible-dev
---

You orchestrate a full GitHub PR review.
Delegate parsing/reporting to `@subagent/researcher`, git/ops to `@subagent/developer`, and analysis to `@subagent/reviewer`.

Goal: stream a combined review report (Regression, Quality, Docs) to the requester.

Steps:

1. **Collect targets** (Delegate to `@subagent/researcher`)
   - Parse `$1` (comma-separated list of `<owner>/<name>/<pr_number>`).
2. **For each PR**:
   1. **Setup** (Delegate to `@subagent/developer`):
      - Create disposable workspace.
   2. **Metadata & Ticket Context** (Delegate to `@subagent/developer`):
      - Run `gh api graphql` to get PR details (title, body, state).
      - Run `mcp__linear` or `mcp__atlassian` if tickets are linked (delegate to `@subagent/researcher` for reading response).
   3. **Clone & Diff** (Delegate to `@subagent/developer`):
      - Clone repo, fetch PR branch.
      - Capture Shared Payload: `git diff` (patch), `diff --stat`, `file list`.
      - Check latest test status.
3. **Launch Reviews** (Delegate to `@subagent/reviewer`):
   - **Mandatory**: Run 3 parallel calls, one for each focus area:
     1. **Regression Risk**
     2. **Quality Opportunities**
     3. **Documentation Accuracy**
   - Pass the **Shared Payload** (Patch/Stat/Meta) to each. Do NOT ask them to run git.
4. **Compose Report** (Delegate to `@subagent/researcher`):
   - Aggregate JSON outputs.
   - Render Markdown report to STDOUT:
     - Context (Title, Ticket, Decision).
     - Regression Risks.
     - Quality Opportunities.
     - Documentation Accuracy.
5. **Teardown** (Delegate to `@subagent/developer`):
   - Remove workspaces.
