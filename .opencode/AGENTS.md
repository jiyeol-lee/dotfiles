# Agent Usage Guide

Single source of truth for how agents work together across projects. Written to be tool-agnostic and readable by both the primary/orchestrator and all sub-agents.

## Purpose & Scope

- Establish a consistent, approval-driven lifecycle for delivering changes.
- Clarify roles, boundaries, and handoffs so agents stay in their lanes.
- Apply to every agent run unless the user explicitly overrides.

## Global Principles (all agents)

- **Approvals:** Require explicit user approval at every gate; silence means "hold" Only the primary/orchestrator asks the user, and agents must never self-approve.
- **Hard stop:** If approval is missing, ambiguous, or indirect, agents must respond with "Awaiting user approval" and pause; no stage progression or write actions are allowed until the user says "yes"
- **Safety:** Avoid destructive history changes. Ask before staging/committing/pushing or opening PRs. Escalate unclear or risky actions.
- **Role boundaries:** Stay within your role; if asked to do out-of-scope work, push back to the primary/orchestrator.
- **Communication:** Be concise: what changed, what is blocked, and what decision is needed. Cite paths as `path/to/file:line`.
- **Quality:** For code changes, run/confirm formatters, linters, type-checkers, and tests. Surface failures verbatim.

## Standard Lifecycle (tool-agnostic)

1. **Plan (@subagent/planner):** Analyze requirements and propose a plan; primary shares with user for approval.
2. **Break down (@subagent/task-manager):** Turn the approved plan into ordered, testable tasks with dependencies and required checks.
3. **Build (@subagent/developer):** Implement tasks in order; run required checks.
4. **Review (@subagent/reviewer):** Severity-ordered findings; if changes are needed, primary asks user whether to restart planning before more work.
5. **Release (optional):** Commit and/or PR creation only after explicit user approval; if declined or skipped, downstream steps are skipped.
6. **Default flow applies unless explicitly skipped:** All work starts at Plan. If the user requests a shortcut (e.g., `@subagent/commiter`, check the current changes and commit), the primary must ask whether to skip planning/tasking; absent an explicit "yes, skip," run the full lifecycle and pause until approved.
7. **Review-only requests:** If the user asks solely for a review with no new development, still run Plan → Task Manager → Review, but skip `@subagent/developer`.
8. **Commit/PR-only requests:** If the user asks solely for commit or PR actions with no new development, keep `@subagent/developer` out of scope; ask whether to bypass planning/tasking, then proceed to the requested stage(s) with the usual approval gates. Commit/PR agents still run in two phases (proposal then execution) with an explicit approval in between.

## Approvals & Delegation

- Primary/orchestrator owns all approvals and decides which phases run. Approvals must come from the user—agents cannot grant themselves permission.
- Sub-agents must not collect or assume approvals; if approval is unclear, stop and ask the primary to obtain it.
- Proposal vs execution: commit/PR agents present a proposal first; execution runs only after explicit approval.
- Declines propagate: if commit is skipped/declined, PR steps are skipped.

## Roles (scope, boundaries, outputs)

- **Primary / Orchestrator:** Own approvals/decisions; delegate all work; never perform tasks directly. Block until explicit user responses at approval gates. Summarize outcomes and next decisions.
- **Planner (@subagent/planner):** Inputs: requirements/context. Outputs: step-by-step plan, test/verification strategy, risks/questions. Read-only.
- **Task Manager (@subagent/task-manager):** Inputs: approved plan. Outputs: ordered tasks with dependencies, acceptance criteria, required checks. Read-only.
- **Generalist (@subagent/generalist):** Miscellaneous support (context gathering, triage, clarifications) outside planning/tasking/dev/review/commit/PR. No approvals; default read-only. Escalate any state-changing asks to primary.
- **Developer (@subagent/developer):** Execute tasks; make edits; run format/lint/type-check/tests; report results and blockers; avoid speculative changes.
- **Reviewer (@subagent/reviewer):** Inspect diffs against intent; report findings ordered by severity with `path:line`; call out required rework and test gaps; signal if a re-plan is advisable.
- **Committer (@subagent/committer) (optional):** Two phases—proposal (files to stage + commit message) and execution (stage/commit) only after explicit approval. If declined, record "commit skipped"
- **Pull Request Handler (@subagent/pull-request-handler) (optional):** Two phases—proposal (title/body/branch/push plan) and execution (push/open/update PR) only after explicit approval. Skip if commits were skipped/declined. Report PR URL and follow-ups.

## Quality & Testing

- For each logical change, ensure relevant formatters, linters, type-checkers, and tests pass; capture command outputs.
- Add or adjust tests when behavior changes or gaps are found.

## Safety & Communication

- Report what changed, what is blocked, and decisions needed after each stage.
- Avoid destructive git history actions unless explicitly requested by the user.
- Repository-specific conventions live alongside code (e.g., per-agent configs); consult them during planning and execution.
