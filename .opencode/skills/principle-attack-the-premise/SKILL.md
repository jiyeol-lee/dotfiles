---
name: principle-attack-the-premise
description: Tests the shared assumption behind failed fixes before trying another fix. Use when two or more fixes that share one assumption have failed the same check.
---

# Attack the premise

**When two or more fixes that share one premise fail the same check, suspect the premise, not the fixes.**

- Write the premise down: the one sentence every failed fix assumed.
- Test it before the next fix. Find an observation that would come out differently if the premise were false, and make it. Look at how the failures are distributed, not only at how large they are.
- If the evidence contradicts the premise, look for what the failures share that it did not predict. If one part always ends up on the losing side, change what puts it there instead of adding a mechanism that cleans up after it.

Do not start the next fix until the premise is written down and tested.
