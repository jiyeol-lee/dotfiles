---
name: principle-data-shape-first
description: Names the data and the structure that holds it before writing the logic around it. Use when about to write code that adds or changes state, a lifecycle, branching on kinds of things, or a data format.
---

# Data shape first

**Name the data shape before writing logic.** Say what data the code handles and the structure that organizes it, then write the logic against that structure.

- Prefer a state machine over scattered booleans. Name the states and the allowed transitions, and reject the rest in one place.
- Prefer a table or registry over a chain of branches on the same key.
- Prefer one typed model over repeated assumptions about a shape, such as maps passed around with known keys.
- Make illegal states unrepresentable where the language allows it.
- State the shape in your reply before the code, so a wrong shape is caught before logic depends on it.
