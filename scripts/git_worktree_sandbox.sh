#!/usr/bin/env bash

# Git Worktree Sandbox Script
# Creates a sandbox worktree for experimentation without polluting your branch namespace.
#
# Branch naming (default): Same as source branch (no prefix)
# Branch naming (-s flag): jiyeollee/sandbox/<timestamp>/<source_branch>
#   - Tracks the source branch (--track)
#   - Example: `gws feat/hello` creates branch `feat/hello`
#   - Example: `gws feat/hello -s` creates branch `jiyeollee/sandbox/010234/feat/hello`
#
# Worktree path: ~/dev/sandbox/<repo>/jiyeollee-sandbox-<timestamp>-<sanitized_branch>
#   - Always includes prefix/timestamp for directory uniqueness (independent of branch naming)
#   - All '/' characters are replaced with '-'
#
# Usage: gws <branch_name> [-s] [-n]
#   <branch_name>  Source branch to create sandbox from
#   -s             Add sandbox prefix to branch name (jiyeollee/sandbox/<timestamp>/<branch>)
#   -n             Open in new tmux window named <repo>__<last_segment>--HH-MM-SS (24-hour)
#                  (e.g., `gws feat/hello/world -n` → window name `myrepo__world--14-35-27`)
#
# Cleanup commands are automatically saved to shell history.

# --- Usage Function ---
_gws_usage() {
  echo "Usage: gws <branch_name> [-s] [-n]"
  echo "  -s    Add sandbox prefix to branch name"
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
  local sandbox_prefix_mode=false
  local dir_identifier
  local needs_local_tracking_branch="false"
  local window_name
  local repo_name
  local timestamp
  local worktree_dir
  local script_dir
  local sandbox_branch
  local sanitized_branch
  local branch_last_segment
  script_dir="$HOME/dotfiles/scripts"

  # Parse arguments
  for arg in "$@"; do
    case "$arg" in
    -s) sandbox_prefix_mode=true ;;
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
  timestamp="$(date +%d%H%M)"

  # Git branch name (configurable based on -s flag)
  if [ "$sandbox_prefix_mode" = true ]; then
    sandbox_branch="jiyeollee/sandbox/${timestamp}/${branch}"
  else
    sandbox_branch="$branch"
  fi

  # Directory path (ALWAYS includes prefix/timestamp for uniqueness - independent of branch naming)
  sanitized_branch="${branch//\//-}"
  dir_identifier="jiyeollee-sandbox-${timestamp}-${sanitized_branch}"
  worktree_dir="$HOME/dev/sandbox/$repo_name/$dir_identifier"
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
    # Fetch to update local refs after creating remote branch
    echo "Fetching to update local refs..."
    git fetch origin "$branch"
    needs_local_tracking_branch="true"
  fi

  # Check if branch exists only on remote (needs local tracking branch)
  if [ "$needs_local_tracking_branch" = "false" ]; then
    if ! git show-ref --verify --quiet "refs/heads/$branch" && \
         git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
      needs_local_tracking_branch="true"
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
    tmux send-keys -t "$window_name" "source '$script_dir/_gws_worker.sh' '$branch' '$sandbox_branch' '$worktree_dir' '$sandbox_prefix_mode' '$needs_local_tracking_branch'" Enter

    # Switch to the new window
    tmux select-window -t "$window_name"

    echo "Opened in new tmux window: $window_name"
    return 0
  fi

  # Non-tmux mode: source worker directly
  source "$script_dir/_gws_worker.sh" "$branch" "$sandbox_branch" "$worktree_dir" "$sandbox_prefix_mode" "$needs_local_tracking_branch"
}

# --- Execute Main Function ---
_gws_main "$@"
