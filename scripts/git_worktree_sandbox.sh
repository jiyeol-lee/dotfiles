#!/usr/bin/env bash

# Git Worktree Sandbox Script
# Creates a sandbox worktree for experimentation without polluting your branch namespace.
#
# Branch naming: sandbox/<timestamp>/<source_branch>
#   - Tracks the source branch (--track)
#   - Example: `gws feat/hello` creates branch `sandbox/1733123456/feat/hello`
#
# Worktree path: ~/dev/sandbox/<repo>/<sanitized_sandbox_branch>
#   - All '/' characters are replaced with '-'
#
# Usage: gws <branch_name> [-n]
#   <branch_name>  Source branch to create sandbox from
#   -n             Open in new tmux window named <repo>__<last_segment>--HH-MM-SS (24-hour)
#                  (e.g., `gws feat/hello/world -n` → window name `myrepo__world--14-35-27`)
#
# Cleanup commands are automatically saved to shell history.

# --- Usage Function ---
_gws_usage() {
  echo "Usage: gws <branch_name> [-n]"
  echo "  -n    Open in new tmux window"
  return 1
}

# --- Helper: Check if branch exists locally or on origin ---
_gws_branch_exists() {
  local branch="$1"
  git show-ref --verify --quiet "refs/heads/$branch" ||
    git show-ref --verify --quiet "refs/remotes/origin/$branch"
}

# --- Main Function ---
_gws_main() {
  # Declare local variables
  local branch=""
  local tmux_window_mode=false
  local window_name
  local repo_name
  local timestamp
  local worktree_dir
  local script_dir
  local sandbox_branch
  local sanitized_sandbox_branch
  local branch_last_segment
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
  timestamp="$(date +%s)"
  sandbox_branch="sandbox/${timestamp}/${branch}"
  sanitized_sandbox_branch="${sandbox_branch//\//-}"
  worktree_dir="$HOME/dev/sandbox/$repo_name/$sanitized_sandbox_branch"
  branch_last_segment="${branch##*/}"

  # Create base directory
  mkdir -p "$HOME/dev/sandbox/$repo_name"

  # Validate branch exists (locally or on origin)
  if ! _gws_branch_exists "$branch"; then
    echo "Info: Branch '$branch' not found. Attempting to create remote tracking branch."
    if ! git push origin origin/HEAD:refs/heads/"$branch"; then
      echo "Error: Failed to create remote tracking branch '$branch'" >&2
      return 1
    fi
  fi

  # Handle tmux window mode
  if [ "$tmux_window_mode" = true ]; then
    local time_suffix
    time_suffix="$(date +%H-%M-%S)"
    window_name="${repo_name}__${branch_last_segment}--${time_suffix}"

    # Create new tmux window
    tmux new-window -n "$window_name"

    # Source worker script in new window
    tmux send-keys -t "$window_name" "source '$script_dir/_gws_worker.sh' '$branch' '$sandbox_branch' '$worktree_dir'" Enter

    # Switch to the new window
    tmux select-window -t "$window_name"

    echo "Opened in new tmux window: $window_name"
    return 0
  fi

  # Non-tmux mode: source worker directly
  source "$script_dir/_gws_worker.sh" "$branch" "$sandbox_branch" "$worktree_dir"
}

# --- Execute Main Function ---
_gws_main "$@"
