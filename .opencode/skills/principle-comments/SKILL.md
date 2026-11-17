---
name: principle-comments
description: Keeps a code comment only when another engineer could not understand the code without it. Use when writing, editing, or reviewing a code comment.
---

# Comments

Add a comment only when another engineer could not understand the code without it. If the code is clear on its own, leave the comment out.

- When code changes, update or remove the comments it affects.
- Do not leave ticket keys such as ABC-1234 in comments.
- A comment that excuses a workaround points at code to fix. Fix the code, or flag it, instead of explaining it.
- A comment that guards a constraint, such as "do not remove" or "keep in sync with X", should become a type, test, or check wherever one can enforce it.
