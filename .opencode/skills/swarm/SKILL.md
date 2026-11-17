---
name: swarm
description: Fans independent work out to parallel workers and returns one report, either covering every slice or picking a race winner by a rule declared before spawning. Not for merging several attempts into one artifact. Use when parallel workers buy coverage or speed, such as checking every package, verifying every PR, exploring partitions, or racing approaches, or for "swarm this".
---

# Swarm

Many workers, one report. Each worker gets its own slice or race arm, and you aggregate their results without merging their work.

## Steps

1. **Frame.**
   1. State the done predicate and the report the swarm must return.
   2. Choose the shape. **Coverage** splits the work into slices, one worker each. **Race** gives N workers the same goal and a different approach, or the same brief on different models. For a race, declare the selection rule before spawning: `first pass`, `rank all`, or `best-of` on a named metric.
   3. Give each worker that writes its own output: a worktree from command #1 of the `worktree` skill when it commits, command #3 when it only needs a throwaway checkout, or `/tmp/agentic-coding-tool/swarm-<slug>/worker-<n>/` when it does not need the repository. Read-only workers get no writable output and are told to change nothing.
   4. When workers verify or measure commits, each brief names the exact SHAs. A measurement brief also names the method: sample count, what one sample is, and order.
2. **Fan out.** Spawn every worker in one message with the subagent tool. Alternate each worker's subagent model across the delegation models, unless the calling skill or the race arms name the models. Every brief stands alone: the goal, the scope, the exact slice or race arm, how to verify, and what to report. Each worker reports `PASS`, `ISSUES`, or `BLOCKED` with evidence. A worker that can prove a defect reports `ISSUES` and lists every issue it can prove, not only the first.
3. **Aggregate.** Read every result. Drop a result that does not record the SHAs and method its brief names, and respawn that worker once. After a second miss, record a gap. A gap does not count as a pass. For coverage, every slice needs a result. For a race, apply the selection rule declared in step 1. If a worker drops out, continue with the rest and note it.
4. **Clean up.** Remove every worktree the swarm created with command #5 of the `worktree` skill, after bringing back any commit the result keeps. For read-only workers, run `git status` to confirm nothing changed.

## Output

Every swarm report includes these sections:

- **Shape**: coverage or race, and the selection rule for a race.
- **Results**: a table with one row per slice or arm: the worker's model, its verdict, and its evidence in one line.
- **Issues**: one line per proven issue, with its slice.
- **Gaps**: slices without a valid result, and workers that dropped out.
