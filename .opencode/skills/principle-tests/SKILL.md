---
name: principle-tests
description: Keeps tests that check behavior callers can observe, and drops tests that only pin the implementation. Use when writing, changing, keeping, or deleting a test, and before restructuring code whose behavior must not change.
---

# Tests

- Write tests for current behavior and requirements, including new or modified behavior.
- Before moving structure, pin current behavior with a characterization test, snapshot, or comparison script that passes before and after. A search, a type check, or lint is not a pin.
- Do not write tests solely to confirm that an old implementation or feature was removed.
- When removing a feature, test any resulting behavior that remains in the requirements.

## Test behavior, not implementation

A test is a claim about what users of the code can observe through its interface: return values, errors, state they can read back, and effects on outside systems. Private helpers, internal call order, and intermediate data are implementation.

Judge each test against two imagined edits:

- **Break the behavior**, such as a wrong value or a skipped or doubled effect. If the test still passes, it proves nothing. The usual causes are a loose assertion, an expected value computed by the code under test, and an assertion on data the test built itself.
- **Change the internals** and keep every observable result. If the test fails, it is pinned to the implementation.

Keep a test that catches the first edit and survives the second. Rewrite or delete the rest. Drive the code through its public interface with a concrete input, and derive the expected value from the requirement. Assert the error type callers branch on, not the message.
