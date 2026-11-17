---
name: orchestrate
description: Gives the default rules for choosing, briefing, and checking subagents. Use before spawning any subagent, and when deciding whether to delegate at all.
---

# Orchestrate

You decide which agent does each piece of work, and you own what each one produces.

## Precedence

When a loaded skill says which agents to spawn, how many, or what to give them, follow the skill. These defaults fill only what it leaves out.

## Defaults

- **Decide whether to delegate.** Delegate work that is independent, bulky, or better done in a fresh context, and describe what you need. The subagents' own descriptions decide which one takes it. Do the work yourself when it is small or depends on context only you hold.
- **Split by files.** Run work on disjoint files in parallel, in one message. Run work that shares files one after another, or in one agent. When parallel delegates write code and build or test it, give each its own worktree with command #1 of the `worktree` skill so builds, tests, and ports do not collide. Have the delegate commit there, bring the commits back to the working branch with `git cherry-pick`, then remove the worktree with command #5 of the `worktree` skill.
- **Brief each delegate fully.** It has no prior context. Give the goal, the paths it may and may not write, the constraints, the prior findings, and the evidence that proves the work is done. Point at files by path instead of pasting their contents. Paste only what exists nowhere but your context, such as an earlier delegate's report. Name the evidence concretely, such as a command and its expected output. If you cannot name the evidence, the work is not scoped yet.
- **Turn playbook steps into instructions.** A delegate does not know playbooks. When the delegated work is part of a playbook, write out the steps it must follow as concrete instructions in the brief, including each check it runs. Do not name the playbook or point at its file.
- **Keep irreversible actions for yourself.** Never delegate an irreversible or outward-facing action, such as pushing, opening or merging a PR, deploying, deleting data, or messaging people. When the delegate's work is done, check it, then take those actions yourself.
- **Respect read-only.** When the user said not to change anything yet, or the playbook is read-only, tell each delegate to change nothing outside `/tmp/agentic-coding-tool`, and run `git status` after it returns to confirm.
- **Use a fresh delegate for new work,** including a fix round or a retry. Give it the original brief, every later directive, and the prior report. Reuse a delegate only when the work needs state that lives in it.
- **Check the work, not the summary.** Read the diff or the artifact before you report it. Send back work that drifts from scope.
- **Retry by cause.** Shrink the scope after a context limit, and rerun after a dropped connection. After two failed retries, do the work yourself or replan around it.
- **Spread fan-out across models.** When a skill or playbook names models for its subagents, ensure to set each subagent's model. For a judgment that matters, such as a root cause, a design pick, or a review verdict, get a second opinion by running the same brief with the subagent model set to whichever of `claude-agent/opus` and `openai/gpt-6.2-sol` you are not running on. Agreement is a strong signal. Disagreement means look closer before acting. Other delegation keeps the default model.
- **Guard your context.** Send bulk reading to subagents, such as large files, long logs, wide searches, and session transcripts, and keep only their summaries in your own context. Read a file yourself when you need its exact text to make an edit or a decision.
