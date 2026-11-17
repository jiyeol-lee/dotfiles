---
name: architect
description: Sketch types, signatures, and module structure before code, then stay in the loop while the implementation fills in the sketch. Use for 'architect this', 'design this', or non-trivial work where jumping to code would lock in the wrong shape.
---

# Architect

Sketch the shape before the code, so a wrong shape is cheap to throw away.

## Steps

1. **Ground.** Read every subsystem the change touches. If the change moves ownership or layering, find why the current shape exists so its reason becomes a constraint.
2. **Write the usage first**: the code a caller would write. Derive the types from it.
3. **Design it twice.** Sketch at least two structurally different designs yourself, whole-shape alternatives rather than tweaks inside one shape. For a large or contested design, run the `arena` skill for this step instead.
4. **Compare and pick.** Prefer the design that hides more behind a smaller public interface, makes illegal states unrepresentable, and stays correct for a contributor who sees one file and copies the nearest example. Graft the best part of a losing design into the winner by hand.
5. **Sketch the winner**: types, signatures, module layout, and `not implemented` bodies or pseudocode. No logic yet.
6. **Implement against the sketch**, unless the user said not to change anything yet. The sketch is the contract. When the code needs to deviate, decide whether the sketch, the requirement, or the implementation is wrong, and say so.
7. **Scrap the sketch when the pattern says so.** The signs are the same workaround appearing twice, unrelated edge cases each needing a special branch, types needing casts or `any`, or callers needing to know internals. Redesign as if the new constraints had been known from the start (`principle-redesign-from-first-principles`), make the new sketch smaller than the old one, and return to step 3.

## Output

Every design includes these sections:

- **Usage**: the caller's code.
- **Shape**: types, signatures, and where each lives.
- **Choice**: the alternatives, which one won and why, and what was grafted in.

Fill each section to fit the design. Add a **Module map** section for larger work, and a comparison table in **Choice** when the alternatives were close.
