---
description: Inspect the latest commits of a branch for shipped regressions.
---

You are coordinating the GitHub Branch Regression flow: delegate input collection, markdown rendering, and the final summary to `@subagent/generalist`; assign all workspace/range/teardown work to `@subagent/developer`; and reserve `@subagent/reviewer` for the regression analysis. Do not perform these steps yourself—always hand them off.

Goal: regression-test the latest commits on a branch by comparing the branch head to the commit immediately before the requested span, ensuring reverted regressions inside that span are ignored (only net changes in the squashed diff), and report remaining risks with the commit that introduced them.

Output handling: `@subagent/reviewer` returns JSON; do not request a schema. Render with this markdown (fill "N/A" when empty):

```markdown
## Branch Regression Report for <owner>/<name> on `<branch>`

### Header

- **Repo:** <repo>
- **Branch:** <branch>
- **Range:** <BASE_COMMIT..HEAD_COMMIT> (requested <COUNT>, actual <ACTUAL_COUNT>)
- **Timestamp:** <ISO time>

### Commit Range

<COMMIT_SUMMARY>

### Diff Stat

<DIFF_STAT or "N/A">

### Regression Risks

- **Finding:** <severity> — <title> (<location>)
  - **Details:** <details>
  - **Suggestion:** <suggestion>
  - **Tests:** <tests or "N/A">
- **Risks noted:** <risks array or "N/A">
- **Tests Summary:** passed <passed> · missing <missing> · failing <failing>
- **Follow-ups:** <follow_ups or "N/A">

### Summary

- **Key takeaways:** <concise summary>
```

Safeguards:

- Work only in a disposable workspace; never push or modify remote state.
- All outputs stream to STDOUT; do not write files outside the workspace.

Steps:

1. **Collect Inputs** (delegate to `@subagent/generalist`)
   - `$1` → `COUNT` (latest commits to inspect). Must be a positive integer; if missing/invalid, stop and ask.
   - `$2` → `BRANCH_NAME` (e.g., `main`, `release/v1`). If missing, request it.
   - Determine `REPO_FULL` (`owner/name`):
     - If `$3` exists, treat it as the slug and validate it matches `<owner>/<name>`.
     - Else try `gh repo view --json nameWithOwner -q .nameWithOwner`.
     - If unresolved, ask for the repo slug before continuing.
2. **Prepare Workspace** (delegate to `@subagent/developer`)
   - `workspace="./branch-regression-${REPO_FULL//\//-}-${BRANCH_NAME}-$(date +%s%N)"`; create it.
   - Clone read-only with buffer depth into the workspace root: `gh repo clone "$REPO_FULL" "$workspace" -- --filter=blob:none --depth=$((COUNT + 50))` (deepen later if needed).
   - In the clone:
     ```
     cd $workspace
     git fetch origin "$BRANCH_NAME" --deepen=$((COUNT + 50)) || git fetch origin "$BRANCH_NAME"
     git checkout -B "${BRANCH_NAME}-analysis" "origin/${BRANCH_NAME}"
     ```
3. **Define Range** (delegate to `@subagent/developer`)
   - `HEAD_COMMIT=$(git rev-parse HEAD)`.
   - `BASE_COMMIT=$(git rev-list --skip="$COUNT" -n 1 HEAD 2>/dev/null || git rev-list --max-parents=0 HEAD)` (fallback to root if fewer commits exist).
   - `ACTUAL_COUNT=$(git rev-list --count "${BASE_COMMIT}..${HEAD_COMMIT}")`; note later if `ACTUAL_COUNT < COUNT` to explain truncation.
   - Gather helpers:
     - `COMMIT_SUMMARY=$(git log --no-merges --pretty=format:'%h %H %an %ad %s' "${BASE_COMMIT}..${HEAD_COMMIT}")`
     - `DIFF_STAT=$(git diff --stat "${BASE_COMMIT}" "${HEAD_COMMIT}")`

- **Capture Diff Payload** (delegate to `@subagent/developer`)
  - Run `git diff --unified=2000 "${BASE_COMMIT}" "${HEAD_COMMIT}"` to capture the full patch and `git diff --name-only "${BASE_COMMIT}" "${HEAD_COMMIT}"` to list impacted files.
  - Store or summarize both outputs so they can be attached to the reviewer payload without rerunning expensive commands.

4. **Run Regression Review** (delegate to `@subagent/reviewer`)
   - Build a payload with `REPO_FULL`, `BRANCH_NAME`, `BASE_COMMIT`, `HEAD_COMMIT`, requested vs actual counts, `${COMMIT_SUMMARY}` (tell it to cite the responsible commit), `${DIFF_STAT}`, the captured patch output, the file list, and any notable files/authors.
   - Remind the reviewer that the program expects three distinct focus areas per `.opencode/AGENTS.md` (Regression Risk, Quality Opportunities, Documentation Accuracy). This command requires a single reviewer invocation scoped strictly to the **Regression Risk** focus area because it is a regression-only sweep; note that Quality Opportunities and Documentation Accuracy are out of scope for this command.
   - Call `@subagent/reviewer` once with that payload, explicitly requesting the Regression Risk focus and instructing it to analyze the squashed diff (`BASE_COMMIT..HEAD_COMMIT`) so reverted changes within the window are ignored. Require that every reported risk is tied back to its originating commit from `${COMMIT_SUMMARY}`, then render the returned JSON with the markdown template.

5. **Return Results** (delegate to `@subagent/generalist`)
   - Emit markdown to STDOUT with:
     - Header: repo, branch, requested vs actual count, timestamp, `BASE_COMMIT..HEAD_COMMIT`.
     - "Commit Range" section → `${COMMIT_SUMMARY}`.
     - Optional "Diff Stat" section when `${DIFF_STAT}` exists.
     - "Regression Risks" section → items rendered from the JSON (`findings`, `risks`, `tests_summary`, `follow_ups`).
   - Close with a short CLI line repeating the inspected range and whether regressions were reported.

6. **Teardown** (delegate to `@subagent/developer`)
   - Remove the temporary workspace.
