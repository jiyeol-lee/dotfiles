#!/bin/bash

# This script shortens a given path for better readability.
# Paths deeper than two levels are truncated to show only the last two segments.

# Input: Path to transform, passed as the first argument to the script
input_path="$1"

# Function to calculate the depth of a path
get_path_depth() {
  local path_segment="$1"
  local path_depth=0
  while [[ "$path_segment" == */* ]]; do
    ((path_depth++))
    path_segment="${path_segment#*/}"
  done
  echo "$path_depth"
}

# Function to format paths exceeding a depth of 2
format_path() {
  local full_path="$1"
  local path_depth
  path_depth=$(get_path_depth "$full_path")

  if ((path_depth > 2)); then
    # Extract the last two segments of the path
    local last_segment="${full_path##*/}"        # Last segment
    full_path="${full_path%/"$last_segment"}"    # Remove the last segment
    local second_last_segment="${full_path##*/}" # Second last segment
    echo "/.../$second_last_segment/$last_segment"
  else
    echo "$full_path"
  fi
}

# Main logic to format the input path
if [[ -z "$input_path" ]]; then
  echo "Error: No path provided." >&2
  exit 1
fi

if [[ "$input_path" == "$HOME"* ]]; then
  # Path starts with the user's home directory
  formatted_path="~$(format_path "${input_path#"$HOME"}")"
elif [[ "$input_path" == /* ]]; then
  # Absolute path
  formatted_path="$(format_path "$input_path")"
else
  # Relative path, treated as is
  formatted_path="$input_path"
fi

echo "$formatted_path"
