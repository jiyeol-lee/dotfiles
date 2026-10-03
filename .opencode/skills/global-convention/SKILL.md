---
name: global-convention
description: Conventions that supersede all of the other conventions. Use when writing code, test code, code comments, documentation.
---

# Global coding convention

Conventions described here supersede all of the convention. you MUST OBEY these conventions.

Prefer the simplest implementation that satisfies the requirements. Preserve required behavior, validation, and error handling. Do not perform unrelated refactoring. If you notice a worthwhile refactoring outside the task's scope, briefly suggest it separately without making the change.

## Comments

- Comment on non-obvious intent, constraints, or usage. _**NEVER**_ restate what the code already makes clear.
- _**ALWAYS**_ update or remove comments when the relevant code changes.
- _**NEVER**_ leave a ticket key name like `ABC-1234`.

## Documentation

- _**ALWAYS**_ describe the current behavior, _**NOT**_ the history of changes. Do not add change summaries or implementation diaries to documentation.
- _**ALWAYS**_ keep explanations concise.
- _**NEVER**_ hard-wrap Markdown prose unless requested.

## Tests

- Write tests for the current behavior and requirements, including new or modified behavior. _**NEVER**_ write tests whose only purpose is to confirm that an old implementation or feature was removed. When removing a feature, test any resulting behavior that remains part of the requirements.
