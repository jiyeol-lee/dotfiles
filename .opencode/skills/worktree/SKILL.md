---
name: worktree
description: Creates, lists, and removes git worktrees through a script that picks their location and copies the .env files a fresh checkout lacks. Not for scratch files that do not need the repository. Use when work needs its own checkout of the current repository, such as parallel delegates that build or test, adversaries or verifiers that must not touch the user's checkout, or a sketch that needs the repository, and when listing or removing worktrees.
---

# Worktree

Run every command from inside the repository as `go run ~/.config/opencode/scripts/worktree/main.go <command>`. Do not call `git worktree add` yourself: the script picks the location and copies the `.env` files a fresh checkout lacks.

## Commands

| #   | Command                      | Use it when                                                                                                                                                             | It prints                                          |
| --- | ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| 1   | `create <slug>`              | The work will be committed, such as a parallel delegate's change or a PR owner's branch. Creates branch `<slug>` from `HEAD`, or checks it out if it exists.            | The worktree path, then the `.env` files it copied |
| 2   | `create <slug> --base <ref>` | The branch should start from another ref, such as a parent PR's branch in a stack.                                                                                      | Same                                               |
| 3   | `create <slug> --detach`     | The checkout is throwaway and needs no branch, such as an adversary or a sketch. Add `--base <ref>` to start at another commit, such as a PR's head SHA for a verifier. | Same                                               |
| 4   | `list`                       | Before cleanup, or to find a worktree's path.                                                                                                                           | `<path> <branch>` per worktree                     |
| 5   | `remove <slug or path>`      | The work is done and committed or discarded. Add `--force` to discard uncommitted changes.                                                                              | `removed <path>`                                   |
| 6   | `prune`                      | Command 4 shows a worktree as `(prunable)`.                                                                                                                             | Nothing                                            |

## Rules

- Name each slug after the run that owns it, such as `interrogate-<slug>-<n>` or `verify-<pr>`, so cleanup can tell what created it.
- Work at the path commands 1 to 3 print, with the shell's working directory set there.
- Remove every worktree you created when the run ends, with command 5, unless the user still needs it.
- After bringing a branch worktree's commits back, delete its branch with `git branch -D <slug>` once you have removed the worktree.
- Use command 5 with `--force` freely on worktrees from command 3. Before forcing a worktree with a branch, confirm its commits are pushed or brought back to the working branch.
- Before removing a worktree you did not create, run `git status --porcelain` inside it. If it has tracked changes, show them and ask the user before removing it.
