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
- **Tools**: Use the Todo tool for complex tasks. Use the Task tool for delegation.

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

### Delegation Guidelines

- **Need docs?** → Delegate to `@subagent/researcher` or `@subagent/developer`
- **Need to check/create issues?** → Delegate to `@subagent/task-manager`
- **Need to link PR to issue?** → Delegate to `@subagent/pull-request-handler`

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
