#!/bin/bash

# Run `gh auth status` command and store the output
output=$(gh auth status)

# Extract all logged-in accounts
logged_in_accounts=$(echo "$output" | grep -o 'Logged in to github\.com account [^ ]*' | cut -d ' ' -f 6)

# Iterate through each logged-in account
for account in $logged_in_accounts; do
  # Check if the account is active
  active=$(echo "$output" | grep "Logged in to github\.com account $account" -A 3 | grep -q 'Active account: true' && echo "true" || echo "false")

  # If the account is active, print it and exit
  if [ "$active" = "true" ]; then
    echo "$account"
    exit
  fi
done

# If no active account is found, print an error message
echo "N/A"
