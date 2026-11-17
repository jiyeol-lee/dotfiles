---
name: principle-surgical-changes
description: Touches only the lines the task needs, and cleans up only its own mess. Use when editing existing code, before touching anything outside the lines the task needs.
---

# Surgical changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Do not perform unrelated refactoring.
- Match existing style, even if you'd do it differently.
- If you notice worthwhile refactoring outside the task's scope, briefly suggest it separately without making the change. Mention unrelated dead code, but don't delete it.
- Keep a problem that existed before your change, such as a flaky test, a typo, or a missing lock, out of this change, even when you can reproduce it. Report it and show that it existed before your change. Fix it only when the user's request covers it, and then in its own commit. A pre-existing failure does not block your work.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless the user asked for that cleanup, where removing it is the task.

Before you report, read your full diff and revert every line that does not trace directly to the user's request.
