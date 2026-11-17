---
name: principle-simplicity-first
description: Prefers the simplest implementation that meets the requirements, with nothing speculative. Use when sizing a change, choosing an approach, or tempted to add a feature, abstraction, option, layer, or error handling beyond what was asked.
---

# Simplicity first

_**Prefer the simplest implementation that satisfies the requirements. Nothing speculative.**_

- If a simpler approach exists, say so. Push back when warranted.
- No features beyond what was asked.
- No abstractions for single-use code.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.
- Preserve required behavior, validation, and error handling.
