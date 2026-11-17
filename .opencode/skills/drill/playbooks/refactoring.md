# Refactoring playbook

You own the contract. The structure changes, the behavior does not. The success measure is lower reader load: fewer layers, branches, and hidden state to trace (`principle-minimize-reader-load`).

If the cleanup reveals a missing feature or a real bug, split it out and ship the structural change first, against the pinned behavior.

## Steps

1. **Pin the behavior first.** Learn the contract of the affected code. Then write a characterization test, snapshot, or comparison script that captures current behavior before any structure moves. Type checks and lint are not a pin.
2. **Name the target shape**: the module layout, types, and call graph you would build today. The reshape must delete branches or invalid states, not add indirection. Code that is already clear and local stays as it is. If the target shape crosses a function boundary, run the `architect` skill.
3. **Subtract before you add.** Delete dead code, collapse one-caller wrappers, drop redundant validation, and remove orphan references before introducing the new shape (`principle-subtract-before-you-add`).
4. **Move in small steps that keep the pin green.** For an API change, migrate every caller and delete the old API in the same change. No compatibility shims and no parallel old and new paths. Check every rename against the files, since renames miss usages in strings, docs, and config. Delegate mechanical edits with the file paths, the names being moved, and the behavior to hold.
5. **Prove behavior is unchanged** on the real artifact, not "it compiles" (`principle-prove-it-works`). For larger reshapes, compare old and new outputs or replay a recorded baseline.
6. **Confirm the change is worth keeping.** If the diff does not lower reader load somewhere, revert it. Count the layers and the state a reader must trace before and after (`principle-minimize-reader-load`).
7. **Commit in order**: the subtraction, then the reshape, then any follow-up cleanup. Each commit passes the pin.
8. **Open the pull request** with the `pull-request` skill.

## Reply

Every reply includes these sections:

- **Structure**: what changed in the structure.
- **Pin**: the test, snapshot, or script you held it against.
- **Equivalence**: the proof that behavior is unchanged.
- **Reader load**: what got simpler to trace.
- **Shipped and reverted**: what landed, and what you reverted and why.

Label each claim per `principle-label-claims`.
