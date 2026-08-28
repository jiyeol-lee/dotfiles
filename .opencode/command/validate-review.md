---
description: Validates the review of a code change, diff, branch, or pull request.
agent: primary/codelens
---

## Workflow

1. **Determine target PR** from the task context (PR number or current branch's PR)
2. **Fetch review data**
   - Use `tool__gh--retrieve-pull-request-info` with `with_resolved: false` to fetch only unresolved review threads
   - Extract file paths, line numbers, comment bodies, and URLs
3. **Gather code context** for each unresolved thread:
   - Read the referenced file using the `path` field
   - Focus on the code around the `line` number (±20 lines context)
4. **Validate each issue**:
   - **Extract Claim**: Identify what the reviewer is asserting
   - **Capture URL**: Preserve the comment URL for report linking
   - **Analyze Reality**: Compare the claim against actual code behavior
   - **Determine Verdict**: ✅ VALID or ❌ INVALID
   - **Assess Confidence**: High / Medium / Low
   - **Document Evidence**: Include relevant code snippets and reasoning
5. **Present report** using the report format

## Verdicts

| Verdict     | Icon | When to Use                                          |
| ----------- | ---- | ---------------------------------------------------- |
| **Valid**   | ✅   | Reviewer's claim accurately describes a real issue   |
| **Invalid** | ❌   | Reviewer's claim does not match actual code behavior |

## Confidence Levels

| Level      | When to Use                                              |
| ---------- | -------------------------------------------------------- |
| **High**   | Code clearly supports or contradicts the claim           |
| **Medium** | Code context is somewhat ambiguous                       |
| **Low**    | Limited context or complex logic requires interpretation |

## Error Handling

| Situation                  | Action                                           |
| -------------------------- | ------------------------------------------------ |
| No unresolved threads      | Report success with zero issues                  |
| File not found             | Mark issue as `partial`, note in recommendations |
| GraphQL query fails        | Report failure with error details                |
| Ambiguous reviewer comment | Mark confidence as `low`, document uncertainty   |
| Line number out of range   | Read available context, note limitation          |

## Report Format

````markdown
## Review Validation Report

**PR**: #X - [PR Title]
**Unresolved Threads**: X total
**Validation Result**: X valid, X invalid

### Status: [✅ All Issues Valid | ❌ X Issues Invalid | ⚠️ Mixed Results]

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

## Summary

| Issue               | Valid?         | Reason              | Link        |
| ------------------- | -------------- | ------------------- | ----------- |
| [Issue description] | ✅ Yes / ❌ No | [Brief explanation] | [View](url) |

**[Recommendation: Changes required / No changes required]**
````

## Constraints

- NEVER respond to or dismiss review comments on GitHub
- NEVER approve, request changes, or merge PRs
- ALWAYS preserve comment URLs for linking
- ALWAYS document code evidence for each verdict
- ALWAYS report all unresolved threads, even if validation is uncertain
