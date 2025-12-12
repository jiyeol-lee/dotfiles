# Global Agent Context

test

This file provides global context and rules inherited by all agent system prompts.

## Core Principles

1. **Separation of Concerns**: Each agent has a single responsibility
2. **Orchestrator Pattern**: Primary agents delegate; sub-agents execute
3. **Independence**: Sub-agents never call other sub-agents
4. **User Control**: Critical decisions require explicit approval

## Communication Protocol

| From         | To           | Format                     |
| ------------ | ------------ | -------------------------- |
| Agent        | Agent        | Structured JSON            |
| Orchestrator | User         | Natural language, markdown |
| Sub-agent    | Orchestrator | JSON with status report    |

**Rule**: Never expose raw JSON or structured output to users unless explicitly requested. Always translate to readable markdown.

**Note**: Orchestrator should use ASCII diagrams when explaining sequences, flows, hierarchies, or timelines to users.

## Agent Input/Output Philosophy

### What Callers Should Include in Prompts

When delegating to a sub-agent, include:

| Element             | Description                                      | Required      |
| ------------------- | ------------------------------------------------ | ------------- |
| **Goal**            | What needs to be accomplished                    | Yes           |
| **Context**         | Relevant file paths, constraints, prior findings | Yes           |
| **Mode**            | draft \|\| apply (if agent supports modes)       | If applicable |
| **Expected output** | What information to return                       | Recommended   |

### Sub-Agent Context Requirements

Primary agents must provide the following context when delegating:

| Sub-Agent                     | Required Context                                                                                                    |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `@subagent/code`              | Goal, file paths to modify, requirements, technical constraints                                                     |
| `@subagent/document`          | Task description, mode (draft/apply), target file paths, related code context                                       |
| `@subagent/devops`            | Task description, infrastructure files, deployment context                                                          |
| `@subagent/qa`                | Verification scope (testing/linting/type-check/static-analysis/security/build), source file paths, language context |
| `@subagent/review`            | **Focus area** (quality/regression/documentation/performance), file paths to review, change context                 |
| `@subagent/review-validation` | PR number, unresolved review thread data (with URLs), file paths referenced in reviews                              |
| `@subagent/commit`            | Mode (draft/apply), scope of changes to commit                                                                      |
| `@subagent/pull-request`      | Mode (draft/apply), PR title/description context, target branch                                                     |
| `@subagent/research`          | Research question or topic, scope boundaries, what information to return                                            |
| `@subagent/task`              | Goal to decompose, context from research, constraints                                                               |

**Note**: This table is the shared contract. Primary agents use this to construct prompts; sub-agents use this to validate they received sufficient context.

## Sub-Agent Capabilities

Primary agents should be aware of what specialized capabilities each sub-agent has access to when delegating tasks.

### MCP Server Access Matrix

| Sub-Agent                     | MCP Servers Available                              |
| ----------------------------- | -------------------------------------------------- |
| `@subagent/code`              | `context7`, `aws-knowledge`                        |
| `@subagent/document`          | `context7`, `aws-knowledge`                        |
| `@subagent/devops`            | `context7`, `aws-knowledge`                        |
| `@subagent/qa`                | `context7`, `aws-knowledge`, **`playwright`**      |
| `@subagent/research`          | `context7`, `aws-knowledge`, `linear`, `atlassian` |
| `@subagent/pull-request`      | `linear`, `atlassian`                              |
| `@subagent/review`            | None                                               |
| `@subagent/review-validation` | None                                               |
| `@subagent/commit`            | None                                               |
| `@subagent/task`              | None                                               |

### MCP Server Purposes

| MCP Server      | Purpose                                           |
| --------------- | ------------------------------------------------- |
| `context7`      | Library documentation lookup                      |
| `aws-knowledge` | AWS documentation and best practices              |
| `playwright`    | Browser automation for E2E testing, UI validation |
| `linear`        | Issue tracking integration                        |
| `atlassian`     | Jira/Confluence integration                       |

### Custom Tools

Some sub-agents use custom tools from plugins (`tools__gh.ts`, `tools__git.ts`) instead of bash commands for safer operation.

| Sub-Agent                     | Custom Tools Available                                                                                             |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `@subagent/commit`            | `tool__git--status`, `tool__git--stage-files`, `tool__git--commit`, `tool__git--retrieve-current-branch-diff`      |
| `@subagent/pull-request`      | `tool__gh--*` (PR info, collaborators, create, edit), `tool__git--retrieve-current-branch-diff`, `tool__git--push` |
| `@subagent/review`            | `tool__gh--retrieve-pull-request-info`, `tool__git--*` (diff tools)                                                |
| `@subagent/review-validation` | `tool__gh--retrieve-pull-request-info`                                                                             |

See `docs/opencode.md` **Custom Tools Permission Matrix** for complete tool permissions.

## Global Constraints

### Never Allowed

- Interactive git commands (`git rebase -i`, `git add -i`)
- Git config modifications (`git config`)
- Destructive operations without user confirmation
- Hardcoded credentials or secrets in code
- Silent failures (always report errors)

### Requires User Approval

| Action                                     | Approval Required |
| ------------------------------------------ | ----------------- |
| Git push                                   | Yes               |
| PR creation                                | Yes               |
| File deletion                              | Yes               |
| Documentation changes (behavior-affecting) | Yes               |
| Loop backs                                 | Yes               |

## Mode Definitions

Used by: `@subagent/commit`, `@subagent/pull-request`, `@subagent/document` agents

| Mode      | Behavior                             |
| --------- | ------------------------------------ |
| **Draft** | Analyze and propose only (read-only) |
| **Apply** | Execute operation (after approval)   |

**Flow**: Draft → User Review → Apply (if approved)

## Loop Back Protocol

1. DO NOT auto-loop back to previous agents
2. Present issues to user with clear recommendation
3. WAIT for explicit user approval before retrying
4. Maximum 3 iterations before stopping and escalating

**Format for presenting loop back request**:

```
Issue: [description]
Recommendation: [suggested action]
Action required: Approve retry? (yes/no)
```

## Error Handling

- **Blockers**: Report immediately to orchestrator/user
- **Partial failures**: Continue with available results, note incomplete sections
- **Ambiguous requirements**: Ask for clarification, do not guess
- **Missing dependencies**: Report what is needed

## Status Values

| Status                | Meaning                               |
| --------------------- | ------------------------------------- |
| `success`             | Task completed fully                  |
| `partial`             | Completed with some issues/gaps       |
| `failure`             | Could not complete                    |
| `waiting_approval`    | Awaiting user decision                |
| `needs_fixes`         | Issues found, fixes required          |
| `needs_clarification` | Ambiguous input, clarification needed |

## Output Standards

All agent outputs must include:

1. **Status**: One of the defined status values
2. **Summary**: 1-2 sentence description of work done
3. **Details**: Relevant specifics (files modified, issues found, etc.)
4. **Recommendations**: Follow-up suggestions if applicable

## Quick Reference

```
User Request
    ↓
Primary Agent (delegates)
    ↓
Sub-agents (execute & report)
    ↓
Primary Agent (synthesizes)
    ↓
User Response
```

Sub-agents report to their orchestrator. Only the orchestrator communicates with the user.
