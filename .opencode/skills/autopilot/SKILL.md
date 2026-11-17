---
name: autopilot
description: Carries one task or a queue of tasks from plan to opened draft pull requests without stopping, settling open questions by experiment and writing the plan first when none exists. Use when the user wants work shipped end to end, such as "autopilot this", "take it to a PR", or "build these and open PRs".
---

# Autopilot

You own the work from plan to verified draft pull requests. The request authorizes pushing the branches this run creates and opening draft PRs for them. Decide reversible calls yourself, act, and report each decision with its reason. Do not stop to ask about them.

Always pause for merging, deploying, deleting data, messaging people, and force-pushing a branch this run did not create. Force-pushing a branch this run created is allowed; use `git push --force-with-lease`.

## Steps

1. **Ticket.** Create or link a ticket only when the user asks for tracking or the repository's instructions require one, in the tracker they name, assigned to the user. If tracking is asked for without a tracker, ask which one now, before going autonomous.
2. **Settle the unknowns.** List what is not yet known. Ask every question only the user can decide in one batch now, with the `grill-me` skill. Settle the rest by experiment, riskiest unknown first.
3. **Plan.** Write the goal, the success criteria, and units that each end in a check. For a queue, list each task and mark which ones build on another task's change. Split a task that mixes kinds so structure-only changes land first, in their own PR. For work that spans repositories, load the `technical-design` skill.
4. **Open the decision log** with the `show-me-your-work` skill when the user is away or the run is long.
5. **Branch.** Each task gets its own branch off the default branch. A task that builds on another branches off that task's branch. Independent tasks can run in parallel, one delegated owner each in its own worktree from command #1 of the `worktree` skill. A dependent task uses command #2 with `--base <parent-branch>`.
6. **Build** each unit, and commit it before starting the next.
7. **Open each draft PR** with the `pull-request` skill. A dependent PR names its parent's branch as its base.
8. **Verify each PR at its head** with a coverage pass of the `swarm` skill, one worker per PR. Each worker runs on a delegation model that did not write the PR, checks out its head in a worktree named `verify-<pr>` from command #3 of the `worktree` skill with `--base <head-sha>`, and exercises the changed behavior on the real surface. CI green is an input, not a verdict. Fix every `ISSUES` result and verify the new head again.
9. **Restack on change.** When a lower PR gets a new head, rebase the PRs above it onto it and push each with `git push --force-with-lease`. A PR whose `git patch-id` the restack leaves unchanged keeps its verdict.
10. **Stop at verified draft PRs.** Do not merge. After the handoff, push nothing without the user's go.

## Reply

Every reply includes these sections:

- **Ticket**: its link, when one exists.
- **Plan**: the units, and the unknowns settled and how.
- **Decisions**: each decision you made on your own, with its reason.
- **PRs**: each PR in stack order, with its link, base, head SHA, and verdict.
- **Waiting on you**: what needs the user before landing.
- **Attention**: per the `show-me-your-work` skill, when a decision log was kept.
