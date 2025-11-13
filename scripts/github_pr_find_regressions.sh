#!/usr/bin/env bash

set -euo pipefail

# Check bash version (require at least 5.0)
if ((BASH_VERSINFO[0] < 5)); then
  echo "Error: This script requires Bash 5.0 or higher. Current version: ${BASH_VERSION}"
  exit 1
fi

# Check if a command is available
check_command() {
  local cmd=$1
  local name=$2
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Error: '$cmd' command not found. Please install $name"
    exit 1
  }
}

# Check if required commands are available
check_command "gh" "GitHub CLI"
check_command "codex" "Codex CLI"
check_command "jq" "jq JSON processor"

# Usage function
usage() {
  echo "Usage: $0 --number <pr_number> --repo <organization_name>/<repository_name>"
  echo ""
  echo "Options:"
  echo "  --number, -n    Pull request number"
  echo "  --repo, -r      Repository in format 'organization/repository'"
  echo "  --help, -h      Show this help message"
  echo ""
  echo "Example: $0 --number 123 --repo myorg/myrepo"
  exit 1
}

# Initialize variables
PR_NUMBER=""
REPO_FULL=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  -h | --help)
    usage
    ;;
  -n | --number)
    PR_NUMBER="$2"
    shift 2
    ;;
  -r | --repo)
    REPO_FULL="$2"
    shift 2
    ;;
  *)
    echo "Error: Unknown option: $1"
    usage
    ;;
  esac
done

# Check if required arguments are provided
if [ -z "$PR_NUMBER" ] || [ -z "$REPO_FULL" ]; then
  echo "Error: Missing required arguments"
  usage
fi

# Split organization/repository
if [[ ! "$REPO_FULL" =~ ^[^/]+/[^/]+$ ]]; then
  echo "Error: Repository must be in format 'organization/repository'"
  usage
fi

ORGANIZATION="${REPO_FULL%/*}"
REPOSITORY="${REPO_FULL#*/}"

# Validate PR number is numeric
if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
  echo "Error: PR number must be numeric"
  exit 1
fi

TMPDIR=$(mktemp -d)

# Fetch PR details
echo "Fetching PR details..."
PR_DATA=$(gh pr view "$PR_NUMBER" --repo "$REPO_FULL" --json title,body,comments,reviews)
PR_TITLE=$(echo "$PR_DATA" | jq -r '.title')
PR_BODY=$(echo "$PR_DATA" | jq -r 'if .body == "" or .body == null then "There is no description for this PR." else .body end')
PR_COMMENTS=$(echo "$PR_DATA" | jq -r 'if (.comments | length) == 0 then "There are no comments on this PR." else .comments[] | "Author: \(.author.login)\nCreated: \(.createdAt)\nBody:\n\(.body)\n---" end')
PR_REVIEWS=$(echo "$PR_DATA" | jq -r 'if (.reviews | length) == 0 then "There are no reviews on this PR." else (.reviews[] | "Reviewer: \(.author.login)\nState: \(.state)\nSubmitted: \(.submittedAt)\nBody:\n\(.body)\n---") end')

# Fetch review comments separately using gh api
echo "Fetching review comments..."
PR_REVIEW_COMMENTS=$(gh api "repos/${REPO_FULL}/pulls/${PR_NUMBER}/comments" --jq 'if length == 0 then "There are no review comments on this PR." else .[] | "Author: \(.user.login)\nPath: \(.path)\nLine: \(.line // .original_line)\nCreated: \(.created_at)\nBody:\n\(.body)\n---" end' 2>/dev/null || echo "There are no review comments on this PR.")

# Construct the prompt
PROMPT="Review pull request ${PR_NUMBER} from ${REPOSITORY} repository in ${ORGANIZATION} organization and identify any regressions.

PR Context:
===========
Title: ${PR_TITLE}

Description:
${PR_BODY}

Comments:
${PR_COMMENTS}

Reviews:
${PR_REVIEWS}

Review Comments:
${PR_REVIEW_COMMENTS}
===========

Use \$(gh) command for investigation.
When you need to read code files, clone the repository first.

Steps:
1. Clone the repository with depth 1 to minimize data transfer with the following command:
   \$(gh repo clone ${ORGANIZATION}/${REPOSITORY} ${TMPDIR}/${REPOSITORY} -- --depth=1)
2. Checkout the pull request branch with:
   \$(git fetch origin pull/${PR_NUMBER}/head:pr-${PR_NUMBER} && git checkout pr-${PR_NUMBER})
3. Analyze the code changes in the pull request to identify any regressions.
4. Report your findings in a clear, concise summary.

Rules:
1. Provide a concise summary of the regressions found with bullet points.
2. If no regressions are found, respond with 'No regressions found.'
3. Do not include any explanations or additional information beyond the summary.
4. Do not perform any actions outside of the specified repository and PR.
5. Make sure not to do anything that would modify the repository or PR.
6. Consider the PR context provided above when analyzing the changes."

echo "Running PR review for:"
echo "  Organization: ${ORGANIZATION}"
echo "  Repository: ${REPOSITORY}"
echo "  PR Number: ${PR_NUMBER}"
echo ""

# Run codex exec with the constructed prompt
codex exec --skip-git-repo-check --sandbox danger-full-access "$PROMPT"

# Clean up temporary directory
echo "Cleaning up temporary files..."
rm -rf "$TMPDIR"
