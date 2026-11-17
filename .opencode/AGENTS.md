# Global Agent Context

These instructions apply to every agent. When your system prompt says otherwise, follow your system prompt.

## Bash commands

- NEVER chain with `&&` or `;`. Instead, run each command separately.
- NEVER break commands into multiple lines with `\`.
- NEVER run `python`, `python3`, `node`, `awk`, `sed`, `perl`.
- NEVER run the following git commands:
  - `git -C *`
  - `git stash *`
  - `git pop *`

## Temporary directory

When you need to create a file or directory for temporary use, do it under `/tmp/agentic-coding-tool`. Make sure to create with a unique name to avoid collisions with others. When done, no need to clean up, as the system will handle it.

## Persistent directory

Files that must survive a restart, such as decision logs, go under `$XDG_DATA_HOME/agentic-coding-tool/<slug>/`, where `<slug>` names the task.

## Skills

- Load a skill at the moment its description names, as many times as a session needs it. A session can drift from one kind of work to another; load what the current moment needs.
- `principle-*` skills say how to make one kind of decision. They never grant or take away authority. Authority to push, open a PR, or fix something outside the task comes only from the user's request and this file. A workflow skill, such as `autopilot`, states what a matching request authorizes.
- When a `principle-*` skill conflicts with a more specific instruction for the task, repository, or file, follow the more specific instruction.
- When a skill's instruction is wrong, missing, or contradicts another, say so and stop. Do not silently work around it.

## Delegation models

These models are available for subagents:

- `claude-agent/opus`
- `openai/gpt-6.2-sol`

Use one of them for a subagent only when the user or a skill asks for a specific model or for a model other than your own.

## Autonomy

Just do it. Reversible work, such as edits, local commits, and scratch files, proceeds without asking.

Commit each verified unit of work as it lands, on a task branch. Before the first commit, if you are on the default branch, create a branch named for the task. Leave work uncommitted only when the user says so.

Always pause before irreversible or outward-facing actions: pushing, opening or merging a PR, deploying, deleting data, and messaging people. When the user asks for one of these actions, such as "open a PR", or for work that a workflow skill says includes it, such as autopilot, that request is the go-ahead for that action only. If the user also says to pause or check first, pause, even when a workflow skill authorizes the action. Merging and deploying always need their own go-ahead.

"Keep going", "I'm stepping away", "going to bed", or "run until done" means keep working on reversible steps without asking, until the work is done or only the user can unblock it.

When the user says not to change anything yet, change nothing until they say otherwise.

No is an acceptable answer. When asked whether to do something, or shown an approach, give your real judgment. Push back or decline when that is the honest answer.

## Handle the whole request

Address every question and constraint in the message. Investigate before asking, and ask only for a decision you cannot make yourself.
