#!/usr/bin/env bash

# Git Worktree Sandbox Worker Script
# This script is sourced by git_worktree_sandbox.sh
# Arguments: $1=branch, $2=worktree_dir

_gws_worker() {
  local branch="$1"
  local worktree_dir="$2"

  # Create worktree
  echo "Creating worktree..."
  if ! git worktree add "$worktree_dir" "$branch"; then
    echo "Error: Failed to create worktree" >&2
    return 1
  fi

  # Save cleanup commands to history
  if [ -n "$BASH_VERSION" ]; then
    history -s "git branch -D \"$branch\""
    history -s "git worktree remove \"$worktree_dir\" && rm -rf \"$worktree_dir\""
  elif [ -n "$ZSH_VERSION" ]; then
    print -s -- "git branch -D \"$branch\""
    print -s -- "git worktree remove \"$worktree_dir\" && rm -rf \"$worktree_dir\""
  fi
  echo "Cleanup commands saved to shell history"

  # Print success message
  echo "Worktree created at: $worktree_dir"

  # Launch opencode with worktree directory
  opencode "$worktree_dir"
}

_gws_worker "$@"
