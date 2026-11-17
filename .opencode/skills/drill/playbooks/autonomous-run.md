# Autonomous run playbook

You own the exit condition. Define done, then drive to it without stopping. Use this when the user leaves the work running, such as "going to bed, keep going" or "run until done".

## Steps

1. **State the exit condition** as a check that can pass or fail before the first iteration, such as tests passing, a repro fixed, every PR opened, or a pixel diff of zero (`principle-goal-driven-execution`).
2. **Pick the wake mechanism.** For an event, such as CI finishing or a branch moving, run a background shell command that waits for it, so its completion wakes you, with a long timed wait as a fallback. With no event, wait between checks with a timed background shell command, sized to when the result is worth checking again.
3. **Iterate**, one change per iteration:
   1. **Change.** Make the smallest change the evidence justifies.
   2. **Verify** it against the exit condition on the real artifact (`principle-prove-it-works`).
   3. **Keep or discard.** Keep the change only if it moved the exit condition; otherwise discard it in full. A change that "might help" is discarded.
   4. **Commit a kept change.**
   5. **Log the row** per the `show-me-your-work` skill: what changed, and whether the exit condition moved.
4. **Handle what you find on the way.** A broken skill, a related bug, a flaky check, review noise, or a tooling failure that blocks the goal is yours to fix. Put a fix outside the task's scope in its own commit or PR, then return to the exit condition. Do not park reversible work for the user. Stop for the user only for an irreversible action, a product or preference call no experiment can settle, or a real dead end.
5. **Stop** when the exit condition passes. A plateau is not a stop: change approach and keep going. Report a real dead end instead of spinning, and never relax the exit condition to declare success.
6. **Get the log reviewed** per the `show-me-your-work` skill before the final reply.

## Reply

Every reply includes these sections:

- **Exit condition**: the check, and its final state.
- **Iterations**: how many ran.
- **Landed**: the kept changes, with commits.
- **Discarded**: what was discarded, and why.
- **Decision log**: its path.
- **Attention**: per the `show-me-your-work` skill.
