---
name: tdd
description: Writes a test that fails for the target behavior before production code changes, then makes it pass with the smallest change. Not for when the only possible test is slow, integration-heavy, flaky, or unclear. Use before changing production code for a bug fix or a new feature when a cheap local test path exists, and when the user asks for TDD, a failing test, or a regression test.
---

# TDD

Make the target behavior executable before changing production code. For a bug, that is the broken behavior. For a feature, it is the new behavior. The test fails before the change and passes after it. Prefer no new test over a bad test.

## Steps

1. **Name the behavior.** For a bug: the intended behavior, the current behavior, and the smallest observable repro. For a feature: the next observable behavior the unit adds, one at a time.
2. **Choose the narrowest check**, in the style of the closest existing test for that code path. Do not build a new harness just to satisfy this skill.
3. **Write the failing test.** Encode the intended behavior, not the implementation (`principle-tests`).
4. **Run it before changing code**, and confirm it fails for the intended reason. If it passes or fails for another reason, fix the test first.
5. **Make the smallest change** that passes it.
6. **Rerun** the new test and the nearby tests. For a feature, repeat from step 1 with the next behavior.

## When a test is impractical

A bad test mostly tests mocks, encodes implementation details, depends on timing or global state, needs expensive infrastructure for a small change, or would be deleted right after. Use the closest executable check instead, such as a script, a repro command, a browser run, or a log assertion.

## Guardrails

- Do not change a test to match a wrong implementation.
- Do not weaken an existing assertion unless the intended behavior changed. Say why it changed.
- Keep each test focused on one behavior.

## Output

Every report includes these sections:

- **Failing before**: the check you ran and the failure it printed, per behavior.
- **Passing after**: the same check passing, plus the nearby tests you reran.

If you have no failing-before evidence, replace **Failing before** with **Fallback check**: why no failing test was practical, and which check you used instead.
