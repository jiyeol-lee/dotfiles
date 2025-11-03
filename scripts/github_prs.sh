#!/bin/bash

gh api graphql -f query='
  query($q:String!) {
    search(query:$q, type:ISSUE, last:50) {
      nodes {
        ... on PullRequest {
          number
          title
          url
          reviewDecision
          bodyText
          repository { name owner { login } }

          comments(last:50) {
            nodes {
              author {
                login
                ... on User { name }
                ... on Organization { name }
              }
              bodyText
              url
              createdAt
            }
          }

          reviews(last:50) {
            nodes {
              author {
                login
                ... on User { name }
                ... on Organization { name }
              }
              bodyText
              state
              url
              submittedAt
            }
          }

          reviewThreads(last:50) {
            nodes {
              isResolved
              comments(last:50) {
                nodes {
                  author {
                    login
                    ... on User { name }
                    ... on Organization { name }
                  }
                  bodyText
                  url
                  createdAt
                  path
                  outdated
                }
              }
            }
          }
        }
      }
    }
  }' \
  -F q="is:pr is:open author:$(gh api user -q .login) sort:updated-desc" \
  --template "$(cat ~/dotfiles/templates/gh_pr_list.gotmpl)"
