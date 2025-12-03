#!/usr/bin/env bash

# Git Worktree Sandbox Worker Script
# This script is sourced by git_worktree_sandbox.sh
# Resolves branch refs (local or remote) before creating the worktree
# Arguments: $1=source_branch, $2=sandbox_branch, $3=worktree_dir

_gws_worker() {
  local source_branch="$1"
  local sandbox_branch="$2"
  local worktree_dir="$3"
  local resolved_source

  # Resolve the source branch to an explicit ref
  if git show-ref --verify --quiet "refs/heads/$source_branch"; then
    # Local branch exists - use it directly
    resolved_source="$source_branch"
  elif git show-ref --verify --quiet "refs/remotes/origin/$source_branch"; then
    # Remote branch exists - use explicit remote ref
    resolved_source="origin/$source_branch"
  else
    echo "Error: Branch '$source_branch' not found locally or on origin" >&2
    return 1
  fi

  # Create worktree
  echo "Creating worktree from '$resolved_source'..."
  if ! git worktree add --track -b "$sandbox_branch" "$worktree_dir" "$resolved_source"; then
    echo "Error: Failed to create worktree" >&2
    return 1
  fi

  # Save cleanup command to history (single chained command)
  if [ -n "$BASH_VERSION" ]; then
    history -s "git worktree remove \"$worktree_dir\" && rm -rf \"$worktree_dir\" && git branch -D \"$sandbox_branch\" && exit"
  elif [ -n "$ZSH_VERSION" ]; then
    print -s -- "git worktree remove \"$worktree_dir\" && rm -rf \"$worktree_dir\" && git branch -D \"$sandbox_branch\" && exit"
  fi
  echo "Cleanup commands saved to shell history"

  # Print success message
  echo "Worktree created at: $worktree_dir"

  # Launch opencode with worktree directory
  opencode "$worktree_dir"
}

_gws_worker "$@"
