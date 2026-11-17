---
name: principle-keep-or-revert
description: Keeps a change only when its check shows it moved the goal, and reverts the rest in full. Use right after making a change whose effect a test or measurement can show, such as an attempt in a loop, an experiment, or a fix that might help.
---

# Keep or revert

**Keep a change only when its check moved. Revert everything else in full.**

- One change per attempt. Never stack untested changes.
- Check it on the real artifact with the same check as the baseline. The result is better, worse, or inconclusive. Inconclusive is a revert.
- A change that "might help" is reverted. When evidence refutes a hypothesis, revert everything it motivated.
- Correctness and simplicity outrank the number. Revert a win that breaks behavior, and keep a simplification that holds the number.
- Commit each kept change on its own before the next attempt, staging only its files.
- If a delegate games the check, discard its work and tighten its brief. If the check itself is wrong, fix the check in its own change instead of routing around it.
