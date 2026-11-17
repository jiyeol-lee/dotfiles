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

## Principle skills

When a `principle-*` skill conflicts with a more specific instruction for the task, repository, or file, follow the more specific instruction.

## Autonomy

Just do it. Reversible work, such as edits, local commits, and scratch files, proceeds without asking.

Always pause before irreversible or outward-facing actions: pushing, opening or merging a PR, deploying, deleting data, and messaging people. When the user asks for one of these actions, such as "open a PR", or runs a playbook that authorizes it, such as autopilot, that request is the go-ahead for that action only. If the user also says to pause or check first, pause, even when a playbook authorizes the action. Merging and deploying always need their own go-ahead.

When the user says not to change anything yet, change nothing until they say otherwise.

No is an acceptable answer. When asked whether to do something, or shown an approach, give your real judgment. Push back or decline when that is the honest answer.

## Handle the whole request

Address every question and constraint in the message. Investigate before asking, and ask only for a decision you cannot make yourself.
