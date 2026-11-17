---
name: principle-measure-before-optimizing
description: Measures and profiles the slow case before changing code for speed, and picks fixes in the order of the performance mantras. Use when code is reported slow, and before any change meant to make code faster.
---

# Measure before optimizing

**Tie every speed change to a measurement. Never read source instead of measuring.**

- Measure the workload the user described: its size, its state, and the case that is slow. Check that the harness does the work it claims, with setup outside the timed part and the result consumed so it cannot be optimized away. Record this baseline before any change.
- Profile the baseline before choosing a fix, in a run you do not report. Do not claim a ceiling without running it.
- Try the performance mantras in order, cheapest first, and stop when one meets the target:
  1. Don't do it. Stop work whose result nothing uses.
  2. Do it, but don't do it again.
  3. Do it less.
  4. Do it later.
  5. Do it when they're not looking.
  6. Do it concurrently.
  7. Do it cheaper.
- Compare after against before with the same command, the same statistic, and enough runs to judge the change against noise. Report one primary number with its unit, before and after. A smaller or different workload is labeled as such, never reported as the requested one.
