---
description: Validate PR review comments against actual code.
agent: primary/plan
---

You are coordinating review comment validation with `@subagent/review-validation`.

Goal: Analyze unresolved PR review comments and determine if each reviewer's claim is valid or invalid by examining the actual code.

Arguments:

- `pr:<number>` - Validate reviews on specific PR
- (none) - Validate reviews on current branch's PR

Steps:

1. **Parse Target** (Delegate to `@subagent/review-validation`)
   - Parse the argument to determine target PR:
     - If `pr:<number>`: Use the specified PR number.
     - If no argument: Detect current branch's PR using `gh pr view --json number -q .number`.
   - Retrieve repository context dynamically:
     ```bash
     gh repo view --json owner -q .owner.login  # Get owner
     gh repo view --json name -q .name          # Get repo name
     ```
   - Verify PR exists and has review comments.

2. **Fetch Review Data** (Delegate to `@subagent/review-validation`)
   - Query GitHub GraphQL API for reviews and review threads with URLs:

     ```bash
     gh api graphql -f query='
       query($owner: String!, $repo: String!, $pr: Int!) {
         repository(owner: $owner, name: $repo) {
           pullRequest(number: $pr) {
             reviews(first: 50) {
               nodes {
                 url
                 author { login }
                 state
                 body
                 submittedAt
               }
             }
             reviewThreads(first: 50) {
               nodes {
                 path
                 line
                 isResolved
                 comments(first: 10) {
                   nodes {
                     body
                     author { login }
                     url
                   }
                 }
               }
             }
           }
         }
       }
     ' -F owner="$(gh repo view --json owner -q .owner.login)" \
       -F name="$(gh repo view --json name -q .name)" \
       -F pr=<number> \
       | jq '.data.repository.pullRequest.reviewThreads.nodes |= map(select(.isResolved == false))'
     ```

   - Filter to unresolved review threads only.
   - Extract file paths, line numbers, comment bodies, and URLs.

3. **Gather Code Context** (Delegate to `@subagent/review-validation`)
   - For each unresolved review thread:
     - Read the referenced file using the `path` field.
     - Focus on the code around the `line` number (±20 lines context).
     - Understand the code's actual behavior and intent.

4. **Validate Each Issue** (Delegate to `@subagent/review-validation`)
   - For each review comment:
     - **Extract Claim**: Identify what the reviewer is asserting or concerned about.
     - **Capture URL**: Preserve the comment URL for report linking.
     - **Analyze Reality**: Compare the claim against actual code behavior.
     - **Determine Verdict**:
       - ✅ **VALID**: Reviewer's concern is accurate and actionable.
       - ❌ **INVALID**: Reviewer misunderstood the code; no change needed.
     - **Document Evidence**: Include relevant code snippets and reasoning.

5. **Present Report**
   - Format the report as follows:

     ````markdown
     ## Review Validation Report

     **PR**: #X - [PR Title]
     **Unresolved Threads**: X total
     **Validation Result**: X valid, X invalid

     ### Status: [✅ All Issues Valid | ❌ X Issues Invalid | ⚠️ Mixed Results]

     ---

     ## Issue 1: [Issue Title from Review] [✅ VALID | ❌ INVALID]

     > 🔗 [View Comment](https://github.com/owner/repo/pull/X#discussion_rXXX)
     > 📁 `path/to/file.ts` @ Line X
     > 👤 @reviewer-username

     ### Review's Claim

     [Summarize what the reviewer stated or claimed]

     ### Reality

     **[The review is correct/incorrect].** Here's why:

     [Detailed analysis explaining why the claim is valid or invalid]

     ```[language]
     // Relevant code evidence
     ```

     ## Issue 2: [Issue Title] [✅ VALID | ❌ INVALID]

     > 🔗 [View Comment](https://github.com/owner/repo/pull/X#discussion_rXXX)
     > 📁 `path/to/file.ts` @ Line X
     > 👤 @reviewer-username

     [Same format as Issue 1]

     ---

     ## Summary

     | Issue               | Valid?         | Reason              | Link        |
     | ------------------- | -------------- | ------------------- | ----------- |
     | [Issue description] | ✅ Yes / ❌ No | [Brief explanation] | [View](url) |

     **[Recommendation: Changes required / No changes required]**
     ````

   - Include clickable URLs to original review comments.
   - Include code snippets where they clarify the analysis.
   - Provide clear reasoning for each verdict.

6. **Safety**
   - This is a READ-ONLY operation. Never modify files.
   - Never respond to or dismiss review comments on GitHub.
   - Never approve, request changes, or merge PRs.
   - Always present findings for human decision-making.

$ARGUMENTS
