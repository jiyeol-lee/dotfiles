# Global Agent Context

## Guidelines

You MUST OBEY guidelines. If you think there is a blocker to follow the guidelines, pause and ask, not silently ignore.

## Bash commands

- NEVER chain with `&&` or `;`. Instead, run each command separately.
- NEVER break commands into multiple lines with `\`.
- NEVER run `python`, `python3`, `node`, `awk`, `sed`, `perl`.
- NEVER run the following git commands:
  - `git -C *`
  - `git worktree *`
  - `git checkout *`
  - `git stash *`
  - `git pop *`

## Temporary directory

When you need to create a file or directory for temporary use, do it under `/tmp/agentic-coding-tool`. Make sure to create with a unique name to avoid collisions with others. When done, no need to clean up, as the system will handle it.
