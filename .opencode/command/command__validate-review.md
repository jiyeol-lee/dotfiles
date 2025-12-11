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

2. **Fetch Review Data** (Delegate to `@subagent/review-validation`)
   - Use `tool__gh--retrieve-pull-request-info` with the PR number (if provided) and `with_resolved: false` to fetch only unresolved review threads.
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
     - **Assess Confidence**: Rate the verdict confidence:
       - **High**: Code clearly supports or contradicts the claim
       - **Medium**: Code context is somewhat ambiguous
       - **Low**: Limited context or complex logic requires interpretation
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
   - Never respond to or dismiss review comments on GitHub.
   - Always present findings for human decision-making.

$ARGUMENTS
