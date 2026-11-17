# Hillclimb playbook

You own the metric and the experiment's integrity. Supervise and review, and delegate the attempts. One change, one measurement, keep or revert. Never stack untested changes, and never claim a win from reading code.

## Steps

1. **Ground the workload, then fix the metric.** Trace the target and name the workload dimensions that move the result, such as data size, state, and concurrency. Pick a case that reproduces the user's complaint; if none does, fix the repro first. Then fix one metric, the direction that counts as better, and a stop check that pairs a target with a minimum number of attempts, such as "at least 50% better than baseline and at least 10 attempts". Use the user's numbers when given.
2. **Build the harness, prove it, freeze it.** Confirm it separates the target case from easier cases, and make it print its error count and a count of the work done. Once frozen, one repeatable command emits the metric as a median of several runs. Record the baseline and a run of the regression tests before any change.
3. **Open the decision log** with the `show-me-your-work` skill, one row per attempt in its measured-loop format. Read the log before each attempt.
4. **Ground each hypothesis** in a specific mechanism, such as "defer X off the startup path because it blocks the first request", not "try caching something". For a performance metric, order hypotheses by the mantras in the Perf issue playbook.
5. **Loop, one hypothesis per attempt.** Run independent hypotheses in parallel, each in its own worktree from command #1 of the `worktree` skill. When the run is unattended, wake between attempts the way the Autonomous run playbook does, but keep this playbook's stop check. For each attempt:
   1. **Make the change.** Delegate it with a tight scope, and review its diff.
   2. **Measure it** with the frozen harness, and run the regression tests.
   3. **Keep or revert.** Keep the change only when the metric moves past the noise and no test result gets worse than the baseline; otherwise revert it in full.
   4. **Commit a kept change**, one commit per change, staging only its files.
   5. **Log the row**, kept or reverted.
6. **Push past the first plateau.** After several rejects in a row, switch category, combine near misses, reread the source, or try something more radical. Correctness and simplicity outrank the number: revert a win that breaks behavior, and keep a simplification that holds the number.
7. **Stop** when the stop check passes, or when the remaining ideas are not worth their cost. Do not relax the stop check to meet it. If you are stuck, say so instead of spinning.
8. **Get the log reviewed** per the `show-me-your-work` skill.
9. **Open the pull request** with the `pull-request` skill, with the kept commits in the order they landed.

## Reply

Every reply includes these sections:

- **Metric**: the metric, its direction, and the target.
- **Result**: baseline → final, with the percent delta.
- **Attempts**: how many were kept and reverted, and each kept change on one line.
- **Decision log**: its path.
- **Next idea**: the best idea to try if pushed further.
- **Attention**: per the `show-me-your-work` skill.
