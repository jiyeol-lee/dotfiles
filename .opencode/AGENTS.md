# Global Agent Context

## Code Style

### Simplicity

Prefer the simplest implementation that satisfies the requirements. Preserve required behavior, validation, and error handling. Do not perform unrelated refactoring. If you notice a worthwhile refactoring outside the task's scope, briefly suggest it separately without making the change.

### Comments

Comment on non-obvious intent, constraints, or usage. Do not restate what the code already makes clear. Update or remove comments when the relevant code changes.

### Documentation

Describe the current behavior, not the history of changes. Do not add change summaries or implementation diaries to documentation. Keep explanations concise. Do not hard-wrap Markdown prose unless requested.

### Tests

Write tests for the current behavior and requirements, including new or modified behavior. Do not write tests whose only purpose is to confirm that an old implementation or feature was removed. When removing a feature, test any resulting behavior that remains part of the requirements.

## Delegation Requirements

Each agent has a single responsibility. If agent has agents to delegate to, delegate to them instead of doing the work itself.

**CRITICAL**: Agent MUST provides full context when delegating the task. Agent who receives the delegation MUST start from zero context and cannot infer prior state.

When delegating, include:

| Element         | Description                                      | Required    |
| --------------- | ------------------------------------------------ | ----------- |
| Goal            | What needs to be accomplished                    | Yes         |
| Context         | Relevant file paths, constraints, prior findings | Yes         |
| Expected output | What information to return                       | Recommended |

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
