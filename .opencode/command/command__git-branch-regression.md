---
description: Inspect the latest commits of a branch for shipped regressions.
agent: primary/flexible-dev
---

You are coordinating the GitHub Branch Regression flow.
Delegate inputs/reporting to `@subagent/researcher`, ops/git to `@subagent/developer`, and analysis to `@subagent/reviewer`.

Goal: regression-test the latest commits on a branch by comparing the branch head to the commit immediately before the requested span.

Steps:

1. **Collect Inputs** (Delegate to `@subagent/developer`)
   - Inputs: `$1` (COUNT), `$2` (BRANCH_NAME), `$3` (REPO_FULL).
   - Validate inputs. If REPO_FULL is missing, run `gh repo view --json nameWithOwner -q .nameWithOwner`.
2. **Prepare Workspace** (Delegate to `@subagent/developer`)
   - Create a temporary workspace `workspace="./branch-regression-..."`.
   - Clone read-only: `gh repo clone "$REPO_FULL" "$workspace" -- --filter=blob:none --depth=$((COUNT + 50))`.
   - `git fetch` and `git checkout` the target branch.
3. **Define Range & Capture Payload** (Delegate to `@subagent/developer`)
   - Identify `HEAD_COMMIT` and `BASE_COMMIT` (skip $COUNT).
   - Generate `COMMIT_SUMMARY` (`git log`).
   - Generate `DIFF_STAT` (`git diff --stat`).
   - Capture `PATCH_OUTPUT` (`git diff --unified=2000`) and `FILE_LIST`.
4. **Run Regression Review** (Delegate to `@subagent/reviewer`)
   - **Constraint**: Explicitly assign focus: **Regression Risk**.
   - Pass the `COMMIT_SUMMARY`, `DIFF_STAT`, `PATCH_OUTPUT`, and `FILE_LIST` in the prompt.
   - Ask to analyze the squashed diff for regressions, ignoring reverted changes.
5. **Return Results** (Delegate to `@subagent/researcher`)
   - Emit markdown to STDOUT using the template:
     - Header (Repo, Branch, Range).
     - Commit Summary.
     - Diff Stat.
     - Regression Risks (from Reviewer output).
6. **Teardown** (Delegate to `@subagent/developer`)
   - Remove the temporary workspace.
