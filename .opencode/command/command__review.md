---
description: Review current branch changes for regressions, quality, and docs.
agent: primary/flexible-dev
---

You orchestrate a review of the current branch changes compared to the main branch.
Delegate git operations to `@subagent/developer` and analysis to `@subagent/reviewer`.

Goal: Stream a combined review report (Regression, Quality, Docs) analyzing all changes in the current branch.

Steps:

1. **Collect Branch Diff** (Delegate to `@subagent/developer`):
   - Determine the base branch (`main` or `master`).
   - Capture Shared Payload:
     - `git diff <base>...HEAD` (full patch)
     - `git diff --stat <base>...HEAD` (summary)
     - `git log --oneline <base>..HEAD` (commit list)
     - List of changed files.
2. **Launch Reviews** (Delegate to `@subagent/reviewer`):
   - **Mandatory**: Run 3 parallel calls, one for each focus area:
     1. **Regression Risk**: Analyze for logic errors, breaking changes, security flaws, and unintended side effects.
     2. **Quality Opportunities**: Review code style, refactoring opportunities, performance improvements, and best practices.
     3. **Documentation Accuracy**: Check if documentation, comments, and type definitions match the code changes.
   - Pass the **Shared Payload** (Patch/Stat/Commits/Files) to each. Do NOT ask them to run git.
   - Each reviewer returns a structured JSON with:
     - `focus_area`: The assigned focus area.
     - `findings`: List of specific issues or observations.
     - `severity`: Overall severity (none, low, medium, high).
     - `recommendations`: Actionable suggestions.
3. **Compose Report** (Delegate to `@subagent/researcher`):
   - Aggregate JSON outputs from all reviewers.
   - Render a Markdown report to STDOUT:
     - **Branch Summary**: Base branch, number of commits, files changed.
     - **Regression Risks**: Issues and recommendations.
     - **Quality Opportunities**: Suggestions for improvement.
     - **Documentation Accuracy**: Gaps or mismatches found.
     - **Overall Assessment**: Summary verdict (LGTM, Minor Issues, Needs Attention).
