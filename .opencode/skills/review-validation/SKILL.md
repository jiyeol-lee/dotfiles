---
name: review-validation
description: Validates PR review comments against actual code by analyzing reviewer claims to determine if they are valid or invalid. Use when user asks to "validate review comments", "check if review feedback is correct", "verify PR review", or "are these review comments valid".
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

## Example Validation

A validated issue looks like this:

**Issue: "Potential null pointer on `user.profile.name`"** — ❌ INVALID (High confidence)

> 🔗 [View Comment](https://github.com/org/repo/pull/45#discussion_r1234)
> 📁 `src/api/users.ts` @ Line 38

**Reviewer claimed**: `user.profile` could be null, causing a runtime error on line 38.

**Reality**: The `user` object is fetched on line 22 with `findUserOrThrow()` which guarantees a non-null `profile` field via the `UserWithProfile` return type. The null case is handled by the thrown exception on line 23.

```ts
// Line 22-23
const user = await findUserOrThrow(userId); // Returns UserWithProfile
// Line 38
const displayName = user.profile.name; // Safe — profile is guaranteed non-null
```

## Report Format

Use the report format in `references/report-format.md` when generating the validation report.

## Constraints

- NEVER respond to or dismiss review comments on GitHub
- NEVER approve, request changes, or merge PRs
- ALWAYS preserve comment URLs for linking
- ALWAYS document code evidence for each verdict
- ALWAYS report all unresolved threads, even if validation is uncertain
