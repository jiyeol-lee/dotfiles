---
name: autonomous-run
description: Re-checks one condition each time something outside the agent changes, such as CI, a deploy, or a merge, and fixes what fails until it passes. Not for building a task from a plan. Use when the user asks to watch something until it passes, such as "watch CI and fix it until green" or "keep this PR green".
---

# Autonomous run

You own the exit condition. Define done, then drive to it without stopping. The request authorizes pushing fixes to the branch being watched. Merging, deploying, and changing the check itself still need the user's go.

## Steps

1. **State the exit condition** as a check that can pass or fail before the first iteration, such as a PR's checks passing on its newest head, or a deploy reporting healthy.
2. **Pick the wake mechanism.** For an event, such as CI finishing or a branch moving, run a background shell command that waits for it, so its completion wakes you, with a long timed wait as a fallback. With no event, wait between checks with a timed background shell command, sized to when the result is worth checking again.
3. **Open the decision log** with the `show-me-your-work` skill.
4. **Iterate**, one change per iteration:
   1. **Diagnose** from the failing check's own output, then reproduce it locally.
   2. **Change.** Make the smallest change the evidence justifies, and keep or revert it per `principle-keep-or-revert`.
   3. **Push** a kept change, then wait for the check on the new head. A result on an earlier head does not count.
   4. **Log the row** per the `show-me-your-work` skill: what changed, and whether the exit condition moved.
5. **Handle what blocks the goal.** A broken tool, a flaky check, or a related bug that blocks the exit condition is yours to fix, in its own commit. Leave everything else and report it. Stop for the user only for an irreversible action, a product or preference call no experiment can settle, or a real dead end.
6. **Stop** when the exit condition passes. A plateau is not a stop: change approach and keep going. Report a real dead end instead of spinning, and never relax the exit condition to declare success.
7. **Get the log reviewed** per the `show-me-your-work` skill before the final reply.

## Reply

Every reply includes these sections:

- **Exit condition**: the check, and its final state on the newest head.
- **Iterations**: how many ran.
- **Landed**: the kept changes, with commits.
- **Discarded**: what was discarded, and why.
- **Decision log**: its path.
- **Attention**: per the `show-me-your-work` skill.
