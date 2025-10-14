#!/usr/bin/env bash
set -euo pipefail

# ---------- required ----------
OWNER="" # must be set via --owner
# ---------- paths ----------
DATA_HOME="${XDG_DATA_HOME:-"$HOME/.local/share"}"
BASE_DIR="$DATA_HOME/gh-custom"
# ------------------------------

show_help() {
  cat <<'EOF'
Usage: repos.sh --owner OWNER [--refresh] [--help]

Manage and browse GitHub repositories for a specific OWNER (user or org).

Prerequisites:
  • GitHub CLI (gh) - https://cli.github.com/
  • jq - https://github.com/jqlang/jq
  • gum - https://github.com/charmbracelet/gum

Options:
  -o, --owner OWNER  (required) Filter repositories by this owner/org (e.g., github).
  --refresh          Fetch a fresh list of repositories from GitHub (ignore cache).
  --help             Show this help message.

Behavior:
  • Cache is saved to:
      $XDG_DATA_HOME/gh-custom/owner-<OWNER>/repos.json
    (base falls back to ~/.local/share)
  • Uses `gum filter` to interactively search repositories by name.
  • When a repository is selected, opens its Pull Requests page
    (https://github.com/<owner>/<repo>/pulls) with your default browser.

Examples:
  repos.sh --owner github
  repos.sh --owner github --refresh
EOF
}

# --------- parse args ----------
REFRESH=0
while [[ $# -gt 0 ]]; do
  case "$1" in
  -o | --owner)
    OWNER="${2-}"
    [[ -z "$OWNER" ]] && {
      echo "Error: --owner requires a value." >&2
      exit 1
    }
    shift 2
    ;;
  --refresh)
    REFRESH=1
    shift
    ;;
  --help | -h)
    show_help
    exit 0
    ;;
  *)
    echo "Unknown option: $1" >&2
    echo "Try --help" >&2
    exit 1
    ;;
  esac
done

# --------- enforce required owner ----------
if [[ -z "$OWNER" ]]; then
  echo "Error: --owner is required." >&2
  echo "Try: repos.sh --owner github" >&2
  exit 1
fi

# --------- derived paths ----------
APP_DIR="$BASE_DIR/owner-$OWNER"
JSON_FILE="$APP_DIR/repos.json"
mkdir -p "$APP_DIR"

# --------- deps check ----------
for cmd in gh jq gum; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Error: $cmd is required but not installed."
    exit 1
  }
done

# --------- fetch ----------
fetch() {
  tmp_json="$(mktemp)"
  gum spin --title "Fetching repos for owner: $OWNER..." -- \
    gh search repos --owner "$OWNER" --limit 1000 --json name,url >"$tmp_json"
  mv "$tmp_json" "$JSON_FILE"
}

# refresh if needed
if [[ $REFRESH -eq 1 || ! -s "$JSON_FILE" ]]; then
  fetch
fi

# --------- build list & select ----------
NAMES=$(jq -r '.[].name' "$JSON_FILE" | sort)
if [[ -z "$NAMES" ]]; then
  echo "No repositories found in cache. Refetching..." >&2
  fetch
  NAMES=$(jq -r '.[].name' "$JSON_FILE" | sort)
  [[ -z "$NAMES" ]] && {
    echo "No repositories found for owner: $OWNER"
    exit 1
  }
fi

SELECTED_NAME="$(printf '%s\n' "$NAMES" | gum filter --placeholder "Search repositories..." | head -n1)"
[[ -z "$SELECTED_NAME" ]] && exit 0

URL="$(jq -r --arg n "$SELECTED_NAME" '.[] | select(.name==$n) | .url' "$JSON_FILE")"
[[ -z "$URL" || "$URL" == "null" ]] && {
  echo "No URL found for $SELECTED_NAME" >&2
  exit 1
}

PR_URL="${URL%/}/pulls"

# --------- open URL ----------
# macOS 'open'; fall back to xdg-open if present; else print
if command -v open >/dev/null 2>&1; then
  open "$PR_URL"
elif command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$PR_URL" >/dev/null 2>&1 &
else
  echo "Open this URL: $PR_URL"
fi
