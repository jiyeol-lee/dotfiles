#!/bin/bash

TEMPLATE_PR_LIST=$(awk '{ gsub(/  /, ""); printf "%s", $0 }' <~/dotfiles/templates/gh_pr_list.gotmpl)
TEMPLATE_SEARCH_PRS=$(awk '{ gsub(/  /, ""); printf "%s", $0 }' <~/dotfiles/templates/gh_search_prs.gotmpl)

echo -e "\n== List of open PRs in the current repository ==\n"
gh pr list --state open --json number,title,reviewDecision,url,state,author,updatedAt --template "$TEMPLATE_PR_LIST"

echo -e "\n== List of open PRs in all repositories that I have created ==\n"
gh search prs --state open --author @me --sort updated --json id,repository,number,title,url,state,author,updatedAt --template "$TEMPLATE_SEARCH_PRS"

echo -e "\n== List of open PRs in all repositories that I have created and approved ==\n"
gh search prs --state open --review approved --author @me --sort updated --json id,repository,number,title,url,state,author,updatedAt --template "$TEMPLATE_SEARCH_PRS"

echo -e "\n== List of open PRs in all repositories that I have created and required review on ==\n"
gh search prs --state open --review required --author @me --sort updated --json id,repository,number,title,url,state,author,updatedAt --template "$TEMPLATE_SEARCH_PRS"

echo -e "\n== List of open PRs in all repositories that I have created and requested changes on ==\n"
gh search prs --state open --review changes_requested --author @me --sort updated --json id,repository,number,title,url,state,author,updatedAt --template "$TEMPLATE_SEARCH_PRS"

echo -e "\n== List of open PRs in all repositories that I have requested review on ==\n"
gh search prs --state open --review-requested @me --sort updated --json repository,number,title,url,state,author,updatedAt --template "$TEMPLATE_SEARCH_PRS"
