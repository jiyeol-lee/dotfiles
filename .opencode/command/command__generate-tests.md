---
description: Generate comprehensive unit tests for a file or function.
agent: primary/flexible-dev
---

You are generating a test suite based on the input `$1`.

Steps:

1. **Analyze Logic** (Delegate to `@subagent/researcher`)
   - Analyze `$1` for scope/inputs/edge cases.
   - Identify framework and test file location.
2. **Write Tests** (Delegate to `@subagent/developer`)
   - **Role Check**: You are the Builder.
   - Check if test file exists.
   - Write new test cases or create new file.
3. **Validate** (Delegate to `@subagent/tester`)
   - Run the new tests.
   - Report Pass/Fail.
   - **Loop**: If fails/syntax errors -> Delegate to `@subagent/developer` to fix -> Repeat Step 3.
