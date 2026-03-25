# Review Report Format

Use this format when generating the code review report.

```markdown
## Code Review Summary

**Target**: [PR #X / Last N commits / Branch diff]
**Focus Area**: [Quality / Regression / Documentation / Performance]
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
