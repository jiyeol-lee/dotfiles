---
description: Review code changes with comprehensive analysis.
agent: primary/dev
---

You are coordinating code review with `@subagent/review`.

Goal: perform comprehensive code review with parallel analysis streams, then present findings with actionable recommendations.

Arguments:

- `pr:<number>` - Review a specific pull request
- `commit:<count>` - Review the last N commits
- (none) - Review current branch changes vs main/master

Steps:

1. **Parse Target** (Delegate to `@subagent/review`)
   - Parse the argument to determine review target:
     - If `pr:<number>`: Fetch PR diff using `gh pr diff <number>`.
     - If `commit:<count>`: Get diff using `git diff HEAD~<count>`.
     - If no argument: Detect base branch and use `git diff <base>...HEAD`.
   - Identify the base branch:
     ```bash
     git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"
     ```
   - Gather the list of modified files.

2. **Gather Context** (Delegate to `@subagent/review`)
   - For each modified file:
     - Read the full file content (not just the diff).
     - Identify the file type and language.
     - Note the change type (added, modified, deleted).
   - **For PR reviews** (`pr:<number>`), fetch full context using:

     ```bash
     gh api graphql -f query='
       query($owner: String!, $name: String!, $number: Int!) {
         repository(owner: $owner, name: $name) {
           pullRequest(number: $number) {
             state
             title
             body
             comments(first: 100) { nodes { author { login } body } }
             reviews(first: 30) { nodes { author { login } body state } }
             reviewThreads(first: 100) {
               nodes {
                 comments(first: 20) { nodes { author { login } body path } }
               }
             }
           }
         }
       }' -F owner="$(gh repo view --json owner -q .owner.login)" -F name="$(gh repo view --json name -q .name)" -F number=<number>
     ```

     - Use this context to:
       - Understand PR description and goals.
       - Avoid duplicating existing review feedback.
       - Consider responses to previous review comments.
     - Also check CI/test status if available: `gh pr checks <number>`.

3. **Parallel Review** (Delegate to `@subagent/review` - 3 parallel streams)
   - Launch three parallel review streams:

   **Stream 1: Quality Review**
   - Code style and formatting consistency.
   - Readability and maintainability.
   - Performance considerations.
   - Best practices for the language/framework.
   - Naming conventions and code organization.

   **Stream 2: Regression Review**
   - Logic errors and edge cases.
   - Breaking changes to existing functionality.
   - Security vulnerabilities (injection, auth, data exposure).
   - Error handling and failure modes.
   - Race conditions or concurrency issues.

   **Stream 3: Documentation Review**
   - Do code comments match the implementation?
   - Are public APIs documented?
   - Do README or docs need updates for behavior changes?
   - Are complex algorithms explained?
   - Changelog entries needed?

4. **Aggregate Findings** (Delegate to `@subagent/review`)
   - Collect results from all three streams.
   - Deduplicate overlapping findings.
   - Categorize by severity:
     - 🔴 **Critical**: Must fix before merge (security, data loss, breaking changes).
     - 🟡 **Warning**: Should fix, may cause issues (bugs, performance, maintainability).
     - 🔵 **Suggestion**: Nice to have (style, minor improvements, optional enhancements).
   - Group findings by file for easier navigation.

5. **Present Report**
   - Format the report as follows:

     ```
     ## Code Review Summary

     **Target**: [PR #X / Last N commits / Branch diff]
     **Files Reviewed**: X files
     **Total Findings**: X critical, X warnings, X suggestions

     ---

     ### 🔴 Critical Issues (X)

     #### File: `path/to/file.ts`
     - **Line X**: [Issue description]
       - **Why**: [Explanation of the problem]
       - **Fix**: [Suggested resolution]

     ---

     ### 🟡 Warnings (X)

     [Same format as critical]

     ---

     ### 🔵 Suggestions (X)

     [Same format as critical]

     ---

     ### ✅ What Looks Good
     - [Positive observations about the code]
     ```

   - Include line numbers and code snippets where helpful.
   - Provide actionable fix suggestions, not just problem descriptions.

6. **Safety**
   - This is a READ-ONLY operation. Never modify files during review.
   - Never auto-approve or merge PRs.
   - Always present findings for human decision-making.

$ARGUMENTS
