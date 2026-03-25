# Review Validation Report Format

Use this format when generating the validation report.

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

---

## Summary

| Issue               | Valid?         | Reason              | Link        |
| ------------------- | -------------- | ------------------- | ----------- |
| [Issue description] | ✅ Yes / ❌ No | [Brief explanation] | [View](url) |

**[Recommendation: Changes required / No changes required]**
````
