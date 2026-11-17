---
name: principle-prove-it-works
description: Verifies every result on the real thing, never on a proxy, a self-report, or "it compiles". Use before declaring any work done, and whenever you are about to trust a result.
---

# Prove it works

**Verify every result by checking the real thing directly.** Do not infer it from a proxy, a self-report, or "it compiles".

- Run the feature, read the actual value, and inspect the diff. Check that a process is running directly, not through state derived from it.
- A delegate's report is a claim. Read its diff or artifact before you repeat it.
- When verification fails, suspect the observation method before the system. When something passes too easily, suspect the measurement before the result.
- An inconclusive check or a check on a different surface is not a pass. Say which it was.
- The strongest proof is a script that reruns the same comparison. Keep its output where the user can rerun it instead of trusting your word.
