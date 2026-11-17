---
name: principle-goal-driven-execution
description: Defines success criteria that can pass or fail, and loops until they are verified. Use when starting multi-step work, when a request has more than one reading, and before declaring work done.
---

# Goal-driven execution

**Define success criteria. Loop until verified.**

- If multiple interpretations exist, present them. Do not pick silently.

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```
