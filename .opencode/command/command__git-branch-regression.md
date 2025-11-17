---
description: Inspect the latest commits of a branch for shipped regressions.
---

You are orchestrating the GitHub Branch Regression subagent defined at `@agent__github-branch-regression.md`.

Goal: regression-test the latest commits on a branch by comparing the branch head to the commit immediately before the requested span, ensuring previously reverted regressions are ignored (only net changes in the aggregated diff), and report any remaining risks alongside the commit that introduced them.

Steps:

1. **Collect Inputs**
   - Treat `$1` as the number of latest commits to inspect (`COUNT`). It must be a positive integer. If missing/invalid, request clarification before proceeding.
   - Treat `$2` as the branch name to analyze (`BRANCH_NAME`, e.g., `main`, `release/v1`). If absent, stop and ask for it.
   - Determine `REPO_FULL` (owner/name):
     1. If `$3` is provided, treat it as the repo slug and validate it matches `<owner>/<name>`.
     2. Otherwise attempt `gh repo view --json nameWithOwner -q .nameWithOwner`.
     3. If both steps fail (e.g., running outside a git repo), request the repo slug explicitly before proceeding.
2. **Prepare Workspace**
   - Set `workspace="./branch-regression-${REPO_FULL//\//-}-${BRANCH_NAME}-$(date +%s%N)"` and create it for all work.
   - Clone the repo read-only: `gh repo clone "$REPO_FULL" "$workspace/repo" -- --filter=blob:none --depth=$((COUNT + 50))` (deepen later if the span exceeds the depth).
   - Inside the clone run:
     ```
     cd "$workspace/repo"
     git fetch origin "$BRANCH_NAME" --deepen=$((COUNT + 50)) || git fetch origin "$BRANCH_NAME"
     git checkout -B "${BRANCH_NAME}-analysis" "origin/${BRANCH_NAME}"
     ```
3. **Define Range (squashed diff)**
   - Let `HEAD_COMMIT=$(git rev-parse HEAD)`.
   - Determine `BASE_COMMIT` by moving `COUNT` commits back: `BASE_COMMIT=$(git rev-list --skip="$COUNT" -n 1 HEAD 2>/dev/null || git rev-list --max-parents=0 HEAD)`. When the branch contains fewer commits than requested, this falls back to the initial commit so the diff covers everything available.
   - Compute `ACTUAL_COUNT=$(git rev-list --count "${BASE_COMMIT}..${HEAD_COMMIT}")`. If `ACTUAL_COUNT < COUNT`, call this out later so users know the span was truncated.
   - Collect helper data:
     - `COMMIT_SUMMARY=$(git log --no-merges --pretty=format:'%h %H %an %ad %s' "${BASE_COMMIT}..${HEAD_COMMIT}")` (captures both short and full SHA plus title/author/date so findings can reference the responsible commit).
     - `DIFF_STAT=$(git diff --stat "${BASE_COMMIT}" "${HEAD_COMMIT}")`
4. **Run Regression Agent**
   - Build a context payload containing: `REPO_FULL`, `BRANCH_NAME`, `BASE_COMMIT`, `HEAD_COMMIT`, requested vs actual commit counts, `${COMMIT_SUMMARY}` (explicitly note that findings must cite the commit responsible), `${DIFF_STAT}`, and any notable files/authors you observed.
   - Invoke `@agent__github-branch-regression.md` once with that payload. Emphasize that the agent should analyze the squashed diff (`BASE_COMMIT..HEAD_COMMIT`) so regressions resolved within the range are not reported, and that every reported risk must reference the originating commit from `COMMIT_SUMMARY`. Capture its output verbatim (regression bullets or `No regressions found.`).
5. **Return Results**
   - Compose a markdown response containing:
     - Summary header (repo, branch, requested vs actual count, timestamp, `BASE_COMMIT..HEAD_COMMIT`).
     - "Commit Range" section with `${COMMIT_SUMMARY}`.
     - Optional "Diff Stat" section for `${DIFF_STAT}` when non-empty.
     - "Regression Risks" section containing the subagent output.
   - Print this response directly so the caller sees it immediately; do not write additional files.
6. **Teardown and Summary**
   - Remove the temporary workspace after the response is emitted.
   - Close with a concise CLI summary reiterating the range inspected and whether regressions were detected.
