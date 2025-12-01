#!/usr/bin/env bash

# Git Worktree Sandbox Script
# Creates a worktree in ~/dev/sandbox/<repo>/<sanitized_branch>.<timestamp>
# Branch names are sanitized: '/' is replaced with '-'
# Usage: gws <branch_name> [-n]
#   -n: Open in new tmux window named <repo>__<branch>

# --- Usage Function ---
_gws_usage() {
  echo "Usage: gws <branch_name> [-n]"
  echo "  -n    Open in new tmux window"
  return 1
}

# --- Main Function ---
_gws_main() {
  # Declare local variables
  local branch=""
  local tmux_window_mode=false
  local window_name
  local repo_name
  local sanitized_branch
  local timestamp
  local worktree_dir
  local script_dir
  script_dir="$HOME/dotfiles/scripts"

  # Parse arguments
  for arg in "$@"; do
    case "$arg" in
    -n) tmux_window_mode=true ;;
    *) branch="$arg" ;;
    esac
  done

  # Validate branch name is provided
  if [ -z "$branch" ]; then
    _gws_usage
    return
  fi

  # Check if inside a git repository
  if [ -z "$(git rev-parse --is-inside-work-tree 2>/dev/null)" ]; then
    echo "Error: Not inside a Git repository." >&2
    return 1
  fi

  # Get repository name
  repo_name="$(basename "$(git rev-parse --show-toplevel)")"

  # Validate tmux mode requirements (early validation)
  if [ "$tmux_window_mode" = true ]; then
    if ! command -v tmux &>/dev/null; then
      echo "Error: tmux is not installed" >&2
      return 1
    fi
    if [ -z "$TMUX" ]; then
      echo "Error: Not inside a tmux session. Use without -n or start tmux first." >&2
      return 1
    fi
  fi

  # Prepare common variables (needed for both modes)
  sanitized_branch="${branch//\//-}"
  timestamp="$(date +%s)"
  worktree_dir="$HOME/dev/sandbox/$repo_name/$sanitized_branch.$timestamp"

  # Create base directory
  mkdir -p "$HOME/dev/sandbox/$repo_name"

  # Handle tmux window mode
  if [ "$tmux_window_mode" = true ]; then
    window_name="${repo_name}__${sanitized_branch}"

    # Create new tmux window
    tmux new-window -n "$window_name"

    # Source worker script in new window
    tmux send-keys -t "$window_name" "source '$script_dir/_gws_worker.sh' '$branch' '$worktree_dir'" Enter

    # Switch to the new window
    tmux select-window -t "$window_name"

    echo "Opened in new tmux window: $window_name"
    return 0
  fi

  # Non-tmux mode: source worker directly
  source "$script_dir/_gws_worker.sh" "$branch" "$worktree_dir"
}

# --- Execute Main Function ---
_gws_main "$@"
