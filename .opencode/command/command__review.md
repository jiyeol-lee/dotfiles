---
description: Review code changes with comprehensive analysis.
agent: primary/build
---

You are coordinating code review with `subagent/review`.

Goal: perform comprehensive code review with parallel analysis streams, then present findings with actionable recommendations.

Arguments:

- `pr:<number>` - Review a specific pull request
- `commit:<count>` - Review the last N commits
- (none) - Review current branch changes vs main/master

Steps:

1. **Parse Target** (Delegate to `subagent/review`)
   - Parse the argument to determine review target:
     - If `pr:<number>`: Use `tool__gh--retrieve-pull-request-diff` with the PR number to fetch the diff.
     - If `commit:<count>`: Use `tool__git--retrieve-latest-n-commits-diff` with the count to get the diff.
     - If no argument: Use `tool__git--retrieve-current-branch-diff` to get current branch changes vs base.
   - Gather the list of modified files.

2. **Gather Context** (Delegate to `subagent/review`)
   - For each modified file:
     - Read the full file content (not just the diff).
     - Identify the file type and language.
     - Note the change type (added, modified, deleted).
   - **For PR reviews** (`pr:<number>`), use `tool__gh--retrieve-pull-request-info` with the PR number to fetch full PR context (state, title, body, comments, reviews, reviewThreads).
     - Use this context to:
       - Understand PR description and goals.
       - Avoid duplicating existing review feedback.
       - Consider responses to previous review comments.

3. **Parallel Review** (Delegate to `subagent/review` - 4 parallel streams)
   - Launch four parallel review streams:
   - Pass all context from Step 2 (file contents, file types, change types, and PR context if available) to each stream to avoid redundant file reads.

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

   **Stream 4: Performance Review**
   - Algorithm complexity (O(n²) patterns, inefficient loops).
   - Memory usage (large allocations, potential leaks).
   - Network/IO efficiency (batching, parallelization).
   - Caching opportunities.
   - Bundle size impact (frontend).
   - Database queries (N+1 patterns, index hints).
   - Async/await patterns (blocking, Promise.all opportunities).

4. **Aggregate Findings** (Delegate to `subagent/review`)
   - Collect results from all four streams.
   - Deduplicate overlapping findings.
   - Categorize by severity:
     - 🔴 **Critical**: Must fix before merge (security, data loss, breaking changes).
     - 🟡 **Warning**: Should fix, may cause issues (bugs, performance, maintainability).
     - 🔵 **Suggestion**: Nice to have (style, minor improvements, optional enhancements).
   - Group findings by file for easier navigation.

5. **Present Report**
   - Format the report as follows:

     ```markdown
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
   - Always present findings for human decision-making.

$ARGUMENTS
