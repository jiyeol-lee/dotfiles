# Global Agent Context

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

## MCP Server Purposes

| MCP Server      | Purpose                                           |
| --------------- | ------------------------------------------------- |
| `context7`      | Library documentation lookup                      |
| `aws-knowledge` | AWS documentation and best practices              |
| `playwright`    | Browser automation for E2E testing, UI validation |
| `linear`        | Issue tracking integration                        |
| `atlassian`     | Jira/Confluence integration                       |

## Custom Tool Purposes

Custom tools from `tools__gh.ts` and `tools__git.ts` plugins replace hardcoded bash commands for safer operation.

| Tool                                              | Purpose                                                              |
| ------------------------------------------------- | -------------------------------------------------------------------- |
| `tool__gh--retrieve-pull-request-info`            | Get comprehensive PR details (state, title, body, comments, reviews) |
| `tool__gh--retrieve-repository-collaborators`     | List repository collaborators (login and name)                       |
| `tool__gh--create-pull-request`                   | Create PR with title, body, and optional reviewers                   |
| `tool__gh--edit-pull-request`                     | Edit PR title, body, or add reviewers                                |
| `tool__gh--retrieve-pull-request-diff`            | Get the diff content of a specific PR                                |
| `tool__gh--retrieve-repository-dependabot-alerts` | Get open Dependabot alerts for the repository                        |
| `tool__git--retrieve-latest-n-commits-diff`       | Get diff for last N commits (1-100)                                  |
| `tool__git--retrieve-current-branch-diff`         | Compare current branch against default branch                        |
| `tool__git--status`                               | Get structured git status (staged, unstaged, untracked)              |
| `tool__git--commit`                               | Create commit with message and optional body                         |
| `tool__git--stage-files`                          | Stage files for commit (specific files or all)                       |
| `tool__git--push`                                 | Push current branch with upstream tracking                           |

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

Used by: `subagent/commit`, `subagent/pull-request`, `subagent/document` agents

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
