---
description: Refactor code to improve quality without changing behavior.
agent: primary/flexible-dev
---

You are orchestrating a safe refactoring process for `$1`.

Steps:

1. **Analyze** (Researcher)
2. **Plan** (Planner + Approval)
3. **Execute** (Delegate to `@subagent/developer`)
   - Apply refactoring.
4. **Verify** (Delegate to `@subagent/tester`)
   - Run tests.
   - **Constraint**: All tests MUST pass.
   - **Loop**: If fails -> Delegate to `@subagent/developer` to fix/revert -> Repeat Step 4.
5. **Review** (Delegate to `@subagent/reviewer`)
   - Constraint: Focus on Quality Opportunities.
6. **Decision**
   - Present review findings to the user.
   - **STOP**: Ask: "Do you want to address these findings?"
   - **Yes**: Loop back to Step 3 (Execute).
   - **No**: Finish.
