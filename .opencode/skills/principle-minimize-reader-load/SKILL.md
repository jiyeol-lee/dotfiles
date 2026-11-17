---
name: principle-minimize-reader-load
description: Reduces the layers a reader traces and the hidden or mutable state they hold in their head. Use when shaping or reviewing code that is hard to trace, and when judging whether a refactor made code simpler.
---

# Minimize reader load

**Reader load is the work a reader does to understand code.** It has two independent parts: the layers to trace between a question and its answer, and the hidden or mutable state to hold in their head. Reduce both.

- Collapse layers that only forward: wrappers with one caller, adapters with no second implementation, and pass-through methods. Inline them.
- Shrink the scope of state: returns over mutations, locals over fields, fields over package state, and package state over globals. Derive a value instead of keeping two copies in sync.
- State an invariant once, at the boundary, not in every consumer.

The test: can a new reader answer "where does X come from?" and "what can change X?" in under 30 seconds? If not, cut layers or cut state.
