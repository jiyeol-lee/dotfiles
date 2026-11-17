---
name: interrogate
description: Has adversaries try to break a change or design, and reports only the findings a run proves, without fixing them. Not for "are we sure?" questions that a cited answer settles. Use when the user asks to challenge, stress-test, or adversarially review a change or design ("interrogate this", "tear this apart", "find blind spots", "try to break it"), and before opening a PR for a contested design.
---

# Interrogate

Adversaries try to break a change or a design. A finding survives only when a run proves it. Report the findings. Do not fix them.

## Steps

1. **Frame.** The scope is what the user names. Otherwise it is the branch diff from its merge base with the base branch, plus the working tree. Restate the intent from the user's message, the commits, and the PR description. Ask the user when the intent is unclear.
2. **Give each adversary its own worktree.** Save the uncommitted changes with `git diff HEAD > /tmp/agentic-coding-tool/interrogate-<slug>/changes.patch`. For each adversary, create a worktree named `interrogate-<slug>-<n>` with command #3 of the `worktree` skill, then run `git apply` with that patch inside it. Repros go there, never in the user's checkout.
3. **Fan out.** Delegate two to four adversaries in one message. Set each one's subagent model, alternating `claude-agent/opus` and `openai/gpt-6.2-sol`. Give each a different attack focus, such as edge-case inputs, error paths, concurrency and lifetimes, callers and compatibility, or data and config safety. Give each its worktree path, the scope, the intent, and this brief:

   > Break this change. Write and run repros only inside your worktree. Prove each finding with a run against the real code, such as a failing test, a repro script, or command output that shows the wrong behavior. For a design or plan, run a prototype or probe the current tree. Report each finding with a title, the exact command and the directory it runs in, the output it printed, and the output the intent requires. Leave out anything you did not run, including style, naming, structure, and risks that need a future change to matter. No findings is a valid result.

4. **Prove.** Rerun each finding's command yourself, in its worktree. Keep a finding when the output shows the failure and the failure breaks the intent. Merge findings that share a root cause. Drop the rest.
5. **Clean up.** Remove each `interrogate-<slug>-<n>` worktree with command #5 of the `worktree` skill, using `--force`.

## Output

Every report includes these sections:

- **Intent**: the restatement.
- **Findings**: each verified finding with the command, the output it printed, how it breaks the intent, and the adversaries that found it. Say "no verified findings" when none survive.
- **Dropped**: for each adversary, how many findings you dropped and why.
