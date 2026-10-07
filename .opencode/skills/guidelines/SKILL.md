---
name: guidelines
description: Guidelines to complete the mission. Use when writing, reviewing, or refactoring.
---

# Guidelines

Behavioral guidelines described here supersede all of the other existing behavioral guidelines. you MUST OBEY following guidelines.

## Simplicity First

_**Prefer the simplest implementation that satisfies the requirements. Nothing speculative.**_

- If a simpler approach exists, say so. Push back when warranted.
- No features beyond what was asked.
- No abstractions for single-use code.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.
- Preserve required behavior, validation, and error handling.

## Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Do not perform unrelated refactoring.
- Match existing style, even if you'd do it differently.
- If you notice worthwhile refactoring outside the task's scope, briefly suggest it separately without making the change. Mention unrelated dead code, but don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## Goal-Driven Execution

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

## Comments

- Comment on non-obvious intent, constraints, or usage. Never restate what the code already makes clear.
- Update or remove comments when the relevant code changes.
- Do not leave ticket keys such as ABC-1234 in comments.

## Documentation

- Describe current behavior, not the history of changes. No change summaries or implementation diaries.
- Keep explanations concise.
- Do not hard-wrap Markdown prose unless requested.

## Tests

- Write tests for current behavior and requirements, including new or modified behavior.
- Do not write tests solely to confirm that an old implementation or feature was removed.
- When removing a feature, test any resulting behavior that remains in the requirements.

## Technical Guidelines

Technical guidelines described here supersede all of the other existing technical guidelines. you MUST OBEY following guidelines.

Make sure to read the right references before writing, reviewing, or refactoring.

1. [Terraform](./references/terraform.md): Terraform code only.
