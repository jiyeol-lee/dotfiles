---
name: principle-subtract-before-you-add
description: Removes complexity first, then builds on the simpler base. Use when sequencing an addition, refactor, or rewrite, before building anything new in an area.
---

# Subtract before you add

**Remove complexity first, then build on the simpler base.** Leave the design slightly simpler, and as capable or more, than you found it.

- Remove what the task makes obsolete before building its replacement. Leave unrelated dead code and redundant checks alone.
- Cut to the minimum before you polish.
- Design for observed usage, not speculative edge cases.
- No validators, parsers, or guards beyond what the requirements demand.
- When a reference adds nothing new, delete it instead of leaving a stub.
