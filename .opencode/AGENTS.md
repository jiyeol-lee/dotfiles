# Agent Usage Guide

## General Principles

- **Be clear**. Prefer simple, structured answers.
- **Be correct**. Prioritize accuracy over creativity unless the user asks otherwise.
- **Be helpful**. Provide examples, steps, or suggestions when useful.
- **Be concise**. Avoid unnecessary padding or overly long explanations.
- **Be real**. If you are not sure, ask for clarification.

## Agent Compliance

- Obey your assigned agent profile (responsibilities, rules, and flow) exactly as defined.
- **Primary Agents**: Act as orchestrators. Delegate work to sub-agents. Do not perform tasks directly.
- **Sub-Agents**: Stay within your defined scope. Report back to the orchestrator with structured results.
- **Tools**:
  - **Built-in Todo Tools** (`todowrite`, `todoread`): Session-scoped, in-memory task tracking for managing work within a conversation.
  - **Custom Task Tools** (`tools__task_*`): Integrate with external task management systems. Only available to specific agents (see Custom Plugin Tools Availability).

## Sub-Agent Registry

| Sub-Agent                        | Role                                                                                    |
| :------------------------------- | :-------------------------------------------------------------------------------------- |
| `@subagent/planner`              | **Architect**. Develops plans, timelines, and resource allocation.                      |
| `@subagent/task-manager`         | **Project Manager**. Organizes and tracks tasks.                                        |
| `@subagent/researcher`           | **Librarian**. Gathers information, reads docs, searches code, and synthesizes reports. |
| `@subagent/developer`            | **Builder**. Writes code and implements technical solutions.                            |
| `@subagent/tester`               | **Validator**. Runs tests and validates fixes.                                          |
| `@subagent/documenter`           | **Scribe**. Creates and maintains documentation.                                        |
| `@subagent/reviewer`             | **Auditor**. Reviews work (read-only).                                                  |
| `@subagent/committer`            | **Git Ops**. **Mode A**: Draft message. **Mode B**: Execute commit.                     |
| `@subagent/pull-request-handler` | **PR Ops**. **Mode A**: Draft details. **Mode B**: Create/Update PR.                    |

## MCP Server Availability

MCP servers are enabled per-agent based on their responsibilities. Primary agents should delegate to the appropriate sub-agent when MCP tools are needed.

| MCP Server      | Available To                                       | Use Case                                     |
| :-------------- | :------------------------------------------------- | :------------------------------------------- |
| `context7`      | researcher, developer, planner, documenter, tester | Library/framework documentation lookup       |
| `aws-knowledge` | researcher, developer, planner, documenter, tester | AWS service documentation and best practices |
| `linear`        | task-manager, planner, pull-request-handler        | Issue tracking and project management        |
| `atlassian`     | task-manager, planner, pull-request-handler        | Jira/Confluence integration                  |

## Custom Plugin Tools Availability

Custom tools from `.opencode/plugin/tools.ts` are disabled globally and enabled per-agent.

| Tool                    | Available To | Use Case                                |
| :---------------------- | :----------- | :-------------------------------------- |
| `tools__task_add`       | planner      | Creating tasks from plans               |
| `tools__task_get`       | researcher   | Retrieving task details for context     |
| `tools__task_mark_done` | tester       | Marking tasks complete after validation |

### Task Workflow for Orchestrators

When delegating to agents that have `tools__task_mark_done` access (`@subagent/tester`):

1. **Provide Identifier**: The orchestrator **MUST** include the task identifier in the prompt if the agent should mark the task as done upon successful testing.
2. **Completion Rule**: `@subagent/tester` should only call `tools__task_mark_done` when:
   - The task identifier was explicitly provided by the orchestrator in the delegation prompt
   - All tests have passed successfully
3. **Example Delegation**:
   ```
   Validate the implementation and run tests.
   If all tests pass, mark task `TASK-123` as done using `tools__task_mark_done`.
   ```

### Task Context for Sub-Agents

When delegating to agents that have `tools__task_get` access (`@subagent/researcher`):

1. **Provide Identifier**: The orchestrator **MUST** include the task identifier in the prompt if the agent should retrieve task details.
2. **Usage Rule**: Agents should only call `tools__task_get` when the task identifier was explicitly provided by the orchestrator.
3. **Example Delegation**:
   ```
   Research the codebase for context.
   Use `tools__task_get` to retrieve details for task `TASK-456`.
   ```

## Parallel Execution Strategy

### Developers

Run multiple developers in parallel **only if** tasks are completely isolated (different files AND different features).

### Reviewers

Always run **3 reviewers in parallel** for comprehensive coverage.
**IMPORTANT**: You MUST explicitly assign one focus area to each reviewer in your prompt to prevent overlap.

1. **Regression Risk**: Logic errors, breaking changes, security.
2. **Quality Opportunities**: Code style, refactoring, performance.
3. **Documentation Accuracy**: Ensuring docs match the code changes.

### Conflict Prevention

1. **Pre-assign scope**: Explicitly tell each agent what to focus on.
2. **Report conflicts**: If an agent sees overlap, pause and report back.
