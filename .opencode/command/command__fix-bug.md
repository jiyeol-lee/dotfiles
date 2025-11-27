---
description: Fix a bug with enforced reproduction steps (TDD).
agent: primary/flexible-dev
---

You are orchestrating a strict Bug Fix workflow.

Steps:

1. **Analysis** (Delegate to `@subagent/researcher`)
   - Analyze bug in `$1`. Locate code.
2. **Create Reproduction** (Delegate to `@subagent/developer`)
   - **Role Check**: You are the Builder.
   - Write a reproduction script/test case that reproduces the bug.
3. **Confirm Failure** (Delegate to `@subagent/tester`)
   - Run the reproduction script.
   - **Constraint**: It MUST FAIL. If it passes, the reproduction is invalid -> Loop back to Step 2.
4. **Fix** (Delegate to `@subagent/developer`)
   - Modify app code to resolve issue.
5. **Verification** (Delegate to `@subagent/tester`)
   - Run reproduction script.
   - **Constraint**: It MUST PASS.
   - **Loop**: If fails -> Back to Step 4.
6. **Review** (Delegate to `@subagent/reviewer`)
   - Focus: Logic/Quality.
7. **Decision**
   - Present review findings to the user.
   - **STOP**: Ask: "Do you want to address these findings?"
   - **Yes**: Loop back to Step 4 (Fix).
   - **No**: Finish.
