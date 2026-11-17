---
name: principle-fix-root-causes
description: Fixes the fault at the first place the system went wrong, not where it surfaced. Use when debugging any failure, such as a bug, a failing test, a CI break, or a stuck deploy.
---

# Fix root causes

**Fix the fault, not the place where it surfaced.** The root cause is the first place the system did something it should not do, or failed to handle a state it should handle.

- Reproduce first, on the surface where it was reported. If it does not reproduce, synthesize the trigger, tighten the conditions, or add logging until it fires.
- Binary-search the cause. List the candidate hypotheses, seeded from the affected code and its history. Each pass, run the check that rules out the most of them. Ask "why" until the answer is a wrong decision in the code, and confirm that mechanism with runtime evidence before you fix it. When stuck, add logging and read the actual state.
- Ask whether the state that triggered the symptom is legitimate. If it is, handle it where the code broke. If it should never exist, a check there hides the bug, so find what produced it. Guards, retries, swallowed errors, clamped values, and discarded state are the usual ways to hide a bug.
- Fix the pattern, not the instance. Find every place with the same fault.
- If finding the deciding fact took a deep dig, propose the cheap, always-on signal, such as a log line or metric, that would have shown it at first look.
