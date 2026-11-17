---
name: principle-goal-driven-execution
description: Defines success criteria that can pass or fail, and loops until they are verified. Use when starting multi-step work, and when a request has more than one reading.
---

# Goal-driven execution

**Define success criteria. Loop until verified.**

- In your first message on a task, restate the user's goal, the problem behind it, and the smallest change you expect. Do not wait for confirmation. If the evidence rules out the change the user asked for, show it and stop.
- If multiple interpretations exist, present them. Do not pick silently.
- Build the check before the change, and record its result on the current code, so done reads as the old value against the new one.

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
