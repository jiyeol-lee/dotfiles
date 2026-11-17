---
name: principle-redesign-from-first-principles
description: Redesigns as if a new requirement had been there from the start, instead of bolting it on. Use when fitting a new requirement into an existing design.
---

# Redesign from first principles

**Do not bolt a new requirement onto the existing design.** Redesign as if the requirement had been a foundational assumption from the start.

- Read every affected file and understand the current design first.
- Ask: "if we wrote this from scratch with this requirement, what would we build?"
- Carry the change through every reference: types, docs, examples, and tests.
- Think through the whole redesign, then deliver it in small steps that each keep the code working. The design may change a lot, but each step stays small, which keeps this compatible with `principle-simplicity-first` and `principle-surgical-changes`.
