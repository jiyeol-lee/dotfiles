#!/usr/bin/env bash

# Git Worktree Sandbox Worker Script
# This script is sourced by git_worktree_sandbox.sh
# Resolves branch refs (local or remote) before creating the worktree
# Arguments: $1=source_branch, $2=sandbox_branch, $3=worktree_dir, $4=create_new_branch ("true"/"false"), $5=needs_local_tracking_branch ("true"/"false")

_gws_worker() {
  local source_branch="$1"
  local sandbox_branch="$2"
  local worktree_dir="$3"
  local create_new_branch="$4"
  local needs_local_tracking_branch="$5"
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
  if [ "$create_new_branch" = "true" ]; then
    # Sandbox prefix mode: Create new tracking branch with sandbox prefix
    if ! git worktree add --track -b "$sandbox_branch" "$worktree_dir" "$resolved_source"; then
      echo "Error: Failed to create worktree" >&2
      return 1
    fi
  elif [ "$needs_local_tracking_branch" = "true" ]; then
    # Remote-only branch: Create local tracking branch with same name
    if ! git worktree add --track -b "$source_branch" "$worktree_dir" "$resolved_source"; then
      echo "Error: Failed to create worktree" >&2
      return 1
    fi
  else
    # Local branch exists: Use existing branch directly (no -b flag)
    if ! git worktree add "$worktree_dir" "$resolved_source"; then
      echo "Error: Failed to create worktree" >&2
      return 1
    fi
  fi

  # Save cleanup command to history (single chained command)
  local cleanup_cmd
  if [ "$create_new_branch" = "true" ]; then
    # Include branch deletion for sandbox branches (uses sandbox_branch name)
    cleanup_cmd="git worktree remove \"$worktree_dir\" --force && git branch -D \"$sandbox_branch\" && exit"
  elif [ "$needs_local_tracking_branch" = "true" ]; then
    # Include branch deletion for newly created local tracking branches (uses source_branch name)
    cleanup_cmd="git worktree remove \"$worktree_dir\" --force && git branch -D \"$source_branch\" && exit"
  else
    # No branch deletion for pre-existing local branches
    cleanup_cmd="git worktree remove \"$worktree_dir\" --force && exit"
  fi

  echo "To clean up the worktree later, run the following command:"
  echo "$cleanup_cmd"

  echo "Worktree created at:"
  echo "$worktree_dir"

  # Save the worktree_dir in clipboard
  if command -v pbcopy &>/dev/null; then
    echo -n "$worktree_dir" | pbcopy
  elif command -v xclip &>/dev/null; then
    echo -n "$worktree_dir" | xclip -selection clipboard
  fi
}

_gws_worker "$@"
