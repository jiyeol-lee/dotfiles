#!/usr/bin/env bash
# Rebuilds tmux window names with per-pane opencode status icons.
#
# One icon per pane in pane-index order: non-opencode panes get the terminal
# glyph, opencode panes get the state recorded by the tmux-status plugin in
# $XDG_RUNTIME_DIR/opencode/tmux-status.json (keyed by pane id).
# pane_current_command is the source of truth for whether opencode is
# running; the store only supplies the state icon. The strip is always
# painted, whether or not opencode is currently running.
#
# Called by the plugin on session events, by zsh precmd when a prompt
# returns (covers the TUI quitting to the shell), and by the tmux
# pane-exited hook (covers killed panes).

set -euo pipefail

store="${XDG_RUNTIME_DIR:-}/opencode/tmux-status.json"

store_json=""
if [ -n "${XDG_RUNTIME_DIR:-}" ] && [ -f "$store" ]; then
  store_json="$(cat "$store")"
fi

state_icon() {
  case "$1" in
  ask) printf '󰌾' ;;
  running) printf '󰔟' ;;
  done) printf '✓' ;;
  *) printf '󰚩' ;;
  esac
}

# Icon for non-opencode panes. Written as UTF-8 bytes because the literal
# glyph (U+F489) does not survive some editors and transports.
other_icon="$(printf '\357\222\211')"

pane_format=$'#{pane_id}\t#{pane_current_command}\t#{pane_current_path}\t#{pane_active}'

tmux list-windows -a -F '#{window_id}' | while IFS= read -r window_id; do
  icons=""
  base=""

  while IFS=$'\t' read -r pane_id command path active; do
    if [ -n "$icons" ]; then
      icons+=" "
    fi

    if [ "$command" = "opencode" ]; then
      state=""
      if [ -n "$store_json" ]; then
        state="$(jq -r --arg p "$pane_id" '.[$p].state // ""' <<<"$store_json" 2>/dev/null || true)"
      fi
      icons+="$(state_icon "$state")"
    else
      icons+="$other_icon"
    fi

    if [ "$active" = "1" ]; then
      base="${path##*/}"
    fi
  done < <(tmux list-panes -t "$window_id" -F "$pane_format")

  if [ -z "$base" ]; then
    continue
  fi

  name="$base $icons"
  current="$(tmux display-message -t "$window_id" -p '#{window_name}')"
  if [ "$current" != "$name" ]; then
    tmux rename-window -t "$window_id" "$name"
  fi
done
