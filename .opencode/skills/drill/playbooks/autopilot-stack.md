# Autopilot stack playbook

You own a queue of tasks, built and verified without stopping, and handed to the user as reviewed PRs. Nothing merges; the user lands them. The request authorizes pushing branches and opening draft PRs for every task in the queue.

## Steps

1. **List the queue** and the order. Mark which tasks build on another task's change.
2. **Run the Autopilot full playbook** from the `drill` skill for each task. Independent tasks branch from the default branch and can run in parallel, one delegated owner each in its own worktree from command #1 of the `worktree` skill. A task that builds on another bases its branch on that task's branch instead of the default branch, using command #2 of the `worktree` skill with `--base <parent-branch>`, and its Open the pull request step names `<parent-branch>` as the PR base.
3. **Restack on change.** When a lower PR gets a new head, rebase the PRs above it onto it, and push each with `git push --force-with-lease`. Force-pushing branches this run created is allowed. A PR whose `git patch-id` is unchanged by the restack keeps its verdict.
4. **Verify each PR independently** at its current head. Delegate one verifier per PR, with its subagent `model` parameter set to whichever of `claude-agent/opus` and `openai/gpt-6.2-sol` did not write it. Each checks out the PR's head in a worktree named `verify-<pr>` from command #3 of the `worktree` skill, with `--base <head-sha>`, exercises the changed behavior on the real surface, and returns `PASS`, `PASS+NOTES`, or `FAIL` with its evidence. CI green is an input, not a verdict.
5. **Stop at verified.** Hand the PRs to the user. After the handoff, push nothing without the user's go.

## Reply

Every reply includes these sections:

- **Stack**: each PR in stack order, with its link, base, verdict, and head SHA.
- **Waiting on you**: what needs the user before landing.
