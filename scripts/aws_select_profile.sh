#!/usr/bin/env bash

CONFIG_FILE="$HOME/.aws/config"

# Ensure config exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "AWS config not found: $CONFIG_FILE" >&2
  return 1
fi

# Ensure gum is available
if ! command -v gum >/dev/null 2>&1; then
  echo "gum is required but not found in PATH." >&2
  return 1
fi

# Extract profile names from config: include [default] and [profile NAME], ignore others (e.g., sso-session)
profiles=$(awk '
  /^\[/ {
    s=$0
    gsub(/^[[:space:]]*\[|\][[:space:]]*$/,"",s)
    if (s == "default") { print "default"; next }
    if (s ~ /^profile[[:space:]]+/) {
      sub(/^profile[[:space:]]+/,"",s)
      print s
    }
  }
' "$CONFIG_FILE" | sort -u)

if [ -z "$profiles" ]; then
  echo "No profiles found in $CONFIG_FILE" >&2
  return 1
fi

# Use gum to choose a profile
selected=$(printf "%s\n" "$profiles" | gum choose --header "Select AWS profile") || {
  echo "Selection cancelled." >&2
  return 1
}

if [ -z "${selected}" ]; then
  echo "No profile selected." >&2
  return 1
fi

echo "Selected profile: $selected"
export AWS_PROFILE="$selected"
