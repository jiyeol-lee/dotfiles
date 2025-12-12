# Multi-Agent System Reference

## Table of Contents

1. [Agent Summary](#agent-summary)
2. [Directory Structure](#directory-structure)
3. [Agent Relationship Diagrams](#agent-relationship-diagrams)
4. [Agent Invocation Reference](#agent-invocation-reference)
5. [Workflow Diagrams](#workflow-diagrams)
6. [MCP Server Matrix](#mcp-server-matrix)
7. [Tool Permission Matrix](#tool-permission-matrix)
8. [Quick Reference](#quick-reference)

## Agent Summary

| Type    | Agent                         | Role                                                             |
| ------- | ----------------------------- | ---------------------------------------------------------------- |
| Primary | `@primary/plan`               | Research and task planning orchestrator                          |
| Primary | `@primary/dev`                | Development workflow orchestrator                                |
| Sub     | `@subagent/research`          | Information gathering                                            |
| Sub     | `@subagent/task`              | Task breakdown and planning                                      |
| Sub     | `@subagent/code`              | Code implementation                                              |
| Sub     | `@subagent/qa`                | Quality assurance (test, lint, type-check, analyze, scan, build) |
| Sub     | `@subagent/commit`            | Git commits (Draft/Apply Mode)                                   |
| Sub     | `@subagent/pull-request`      | PR management (Draft/Apply Mode)                                 |
| Sub     | `@subagent/document`          | Documentation (Draft Mode)                                       |
| Sub     | `@subagent/devops`            | DevOps and infrastructure                                        |
| Sub     | `@subagent/review`            | Code review (4 focus areas)                                      |
| Sub     | `@subagent/review-validation` | Validates PR review comment accuracy against actual code         |

## Directory Structure

```
.opencode/
├── AGENTS.md                           # Global rules (existing)
├── opencode.json                       # Configuration (existing)
│
├── agent/
│   ├── primary/                        # Primary agents (orchestrators)
│   │   ├── plan.md                     # @primary/plan
│   │   └── dev.md                      # @primary/dev
│   │
│   └── subagent/                       # Sub-agents (specialists)
│       ├── research.md                 # @subagent/research
│       ├── task.md                     # @subagent/task
│       ├── code.md                     # @subagent/code
│       ├── qa.md                       # @subagent/qa
│       ├── commit.md                   # @subagent/commit
│       ├── pull-request.md             # @subagent/pull-request
│       ├── document.md                 # @subagent/document
│       ├── devops.md                   # @subagent/devops
│       ├── review.md                   # @subagent/review
│       └── review-validation.md        # @subagent/review-validation
│
├── command/                            # Commands
│   ├── command__commit.md              # Shortcut for commit workflow
│   ├── command__pull-request.md        # Shortcut for PR workflow
│   ├── command__review.md              # Shortcut for code review
│   └── command__validate-review.md     # Shortcut for PR review validation
│
├── plugin/                             # Plugins
│   └── notifications.ts
│
└── themes/                             # Themes
    └── opencode-custom.json
```

## Agent Relationship Diagrams

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                   USER REQUEST                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                          │
                    ┌─────────────────────┴─────────────────────┐
                    ▼                                           ▼
┌─────────────────────────────────┐       ┌─────────────────────────────────┐
│         @primary/plan           │       │           @primary/dev          │
│                                 │       │                                 │
│   (Research & Planning)         │       │   (Development Workflow)        │
└────────────────┬────────────────┘       └────────────────┬────────────────┘
                 │                                         │
                 ▼                                         ▼
┌───────────────────────────────────────────────┐   ┌───────────────────────────────────────────────────────────────────────────┐
│              PLANNING SUB-AGENTS              │   │                          DEVELOPMENT SUB-AGENTS                           │
│         (Dedicated to @primary/plan)          │   │                          (Used by @primary/dev)                           │
├───────────────────────────────────────────────┤   ├───────────────────────────────────────────────────────────────────────────┤
│                                               │   │                                                                           │
│  ┌────────────────────┐  ┌────────────────┐   │   │  ┌────────────────┐  ┌──────────────┐  ┌────────────────────┐             │
│  │ @subagent/research │  │ @subagent/task │   │   │  │ @subagent/code │  │ @subagent/qa │  │ @subagent/document │             │
│  └────────────────────┘  └────────────────┘   │   │  └────────────────┘  └──────────────┘  └────────────────────┘             │
│                                               │   │                                                                           │
│                                               │   │  ┌──────────────────┐  ┌───────────────────┐                              │
│                                               │   │  │ @subagent/devops │  │ @subagent/review* │                              │
│                                               │   │  └──────────────────┘  └───────────────────┘                              │
│                                               │   │                                                                           │
│                                               │   │  * review also available via /command__review                             │
└───────────────────────────────────────────────┘   └───────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           COMMAND-TRIGGERED SUB-AGENTS                              │
│        (Invoked ONLY via user commands - NOT by orchestrators)                      │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│    ┌────────────────────────────────────┐    ┌────────────────────────────────────┐ │
│    │      @subagent/commit              │    │      @subagent/pull-request        │ │
│    │                                    │    │                                    │ │
│    │      /command__commit              │    │      /command__pull-request        │ │
│    └────────────────────────────────────┘    └────────────────────────────────────┘ │
│                                                                                     │
│    ┌────────────────────────────────────┐                                           │
│    │      @subagent/review-validation   │                                           │
│    │                                    │                                           │
│    │      /command__validate-review     │                                           │
│    └────────────────────────────────────┘                                           │
│                                                                                     │
│    NOTE: These agents are ONLY invoked via user commands, not automatically         │
│          by orchestrators. See "Agent Invocation Reference" section.                │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### Key Points

- `@primary/plan` has its own dedicated sub-agents (`@subagent/research`, `@subagent/task`) and does NOT use development sub-agents
- `@primary/dev` uses the development sub-agents (`@subagent/code`, `@subagent/qa`, `@subagent/document`, `@subagent/devops`, `@subagent/review`)
- Sub-agents never call other sub-agents; they only report to their orchestrator
- `@subagent/commit` and `@subagent/pull-request` are ONLY invoked via commands (`/command__commit`, `/command__pull-request`)
- `@subagent/review` is invoked by orchestrators AND available via `/command__review` command

### Parallel Execution in Phase 1

`@primary/dev` supports parallel sub-agent execution in Phase 1 when work items are **isolated**:

**Isolation Criteria:**

- No file overlap between work items
- No import/dependency relationships
- No behavioral coupling

**Execution Decision:**

| Scenario                       | Execution Strategy                   |
| ------------------------------ | ------------------------------------ |
| Single work item               | Sequential (one sub-agent)           |
| Multiple items, all isolated   | **PARALLEL** (concurrent sub-agents) |
| Multiple items, any dependency | Sequential (in dependency order)     |
| Uncertain                      | Sequential (safe default)            |

**Default to sequential when uncertain.** Parallel execution is an optimization, not a requirement.

**Tracking:**

- Single execution: `work_agent = "code"` (string)
- Parallel execution: `work_agents = ["code", "devops"]` (array)

## Agent Invocation Reference

### Command-Triggered Only

These agents are exclusively triggered by user commands, not by orchestrators:

| Agent                         | Command                     | Flow                               |
| ----------------------------- | --------------------------- | ---------------------------------- |
| `@subagent/commit`            | `/command__commit`          | Draft Mode → Approval → Apply Mode |
| `@subagent/pull-request`      | `/command__pull-request`    | Draft Mode → Approval → Apply Mode |
| `@subagent/review-validation` | `/command__validate-review` | Fetch → Analyze → Report           |

### Orchestrator-Invoked (also available via command)

| Agent              | Invoked By                                 |
| ------------------ | ------------------------------------------ |
| `@subagent/review` | Orchestrator OR `/command__review` command |

### Orchestrator-Invoked Only

These agents are invoked by primary agents as part of workflows:

| Agent                | Used By              |
| -------------------- | -------------------- |
| `@subagent/research` | `@primary/plan` only |
| `@subagent/task`     | `@primary/plan` only |
| `@subagent/code`     | `@primary/dev`       |
| `@subagent/qa`       | `@primary/dev`       |
| `@subagent/document` | `@primary/dev`       |
| `@subagent/devops`   | `@primary/dev`       |

## Workflow Diagrams

### Plan Agent Workflow

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                              @primary/plan                                    │
│                       (Research & Planning Orchestrator)                      │
└───────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        │ 1. Receive planning request
                                        ▼
                          ┌───────────────────────────────┐
                          │     Analyze Requirements      │
                          │     Identify research needs   │
                          └───────────────────────────────┘
                                        │
              ┌─────────────────────────┴─────────────────────────┐
              │                                                   │
              │ 2. Parallel research                              │
              │    (if multiple topics)                           │
              ▼                                                   ▼
    ┌───────────────────┐                           ┌───────────────────┐
    │    @subagent/     │                           │    @subagent/     │
    │     research      │                           │     research      │
    │    (Topic A)      │                           │    (Topic B)      │
    └─────────┬─────────┘                           └─────────┬─────────┘
              │                                               │
              │ Report findings                               │ Report findings
              └───────────────────────┬───────────────────────┘
                                      │
                                      ▼
                          ┌───────────────────────────────┐
                          │     Synthesize Research       │
                          │        @primary/plan          │
                          └───────────────────────────────┘
                                        │
                                        │ 3. Delegate task breakdown
                                        ▼
                              ┌───────────────────┐
                              │    @subagent/     │
                              │       task        │
                              └─────────┬─────────┘
                                        │
                                        │ Report task plan
                                        ▼
                          ┌───────────────────────────────┐
                          │    Review & Finalize Plan     │
                          │       Present to User         │
                          └───────────────────────────────┘

LOOP LIMIT: Max 3 research ↔ task cycles before asking user
```

### Dev Agent Workflow

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                              @primary/dev                                     │
│                        (Development Workflow)                                 │
└───────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        │ 1. Receive development task
                                        ▼
                          ┌───────────────────────────────┐
                          │    ASSESS TASK COMPLEXITY     │
                          │                               │
                          │    Factors considered:        │
                          │    • Scope of changes         │
                          │    • Files affected           │
                          │    • Risk level               │
                          │    • Dependencies             │
                          └───────────────────────────────┘
                                        │
              ┌─────────────────────────┴─────────────────────────┐
              │                                                   │
              ▼                                                   ▼
    ┌───────────────────────────┐               ┌───────────────────────────┐
    │       TRIVIAL TASK        │               │       COMPLEX TASK        │
    │                           │               │                           │
    │   Criteria:               │               │   Criteria:               │
    │   • Single file           │               │   • Multiple files        │
    │   • Low risk              │               │   • Breaking changes      │
    │   • No behavior change    │               │   • API changes           │
    │   • Quick fix             │               │   • New features          │
    │                           │               │   • Refactoring           │
    └─────────────┬─────────────┘               └─────────────┬─────────────┘
                  │                                           │
                  ▼                                           ▼
    ┌───────────────────────────────────┐       ┌───────────────────────────────────┐
    │       TRIVIAL WORKFLOW            │       │         FULL WORKFLOW             │
    │                                   │       │                                   │
    │   1. Work Phase                   │       │   1. Work Phase                   │
    │      • Decompose task             │       │      • Decompose into work items  │
    │      • Check isolation criteria   │       │      • Check isolation criteria   │
    │      • Parallel if isolated       │       │      • Parallel if isolated       │
    │      • Sequential if dependent    │       │      • Invoke sub-agents          │
    │                                   │       │                                   │
    │   2. QA Phase (Conditional)       │       │   2. Doc Check (Conditional)      │
    │      SKIP if document-only        │       │      • Skip if document-only      │
    │      RUN @subagent/qa otherwise   │       │      • Draft via @subagent/doc    │
    │                                   │       │      • MANDATORY user approval    │
    │   3. Parallel Review (4x)         │       │                                   │
    │      • Quality                    │       │   3. QA Phase (Conditional)       │
    │      • Regression                 │       │      • Skip if document-only      │
    │      • Documentation              │       │      • Run @subagent/qa           │
    │      • Performance                │       │                                   │
    │                                   │       │   4. Parallel Review (4x)         │
    │   4. Report completion            │       │      • Quality                    │
    │                                   │       │      • Regression                 │
    │   NOTE: No Doc Check              │       │      • Documentation              │
    │   (no behavior change expected)   │       │      • Performance                │
    │                                   │       │                                   │
    │                                   │       │   5. Issue Resolution             │
    │                                   │       │      • Present issues to user     │
    │                                   │       │      • Wait for decision          │
    └───────────────────────────────────┘       └───────────────────────────────────┘

    ╔═══════════════════════════════════════════════════════════════════════╗
    ║  ADAPTIVE RULES:                                                      ║
    ║                                                                       ║
    ║  • Typo fix (code)    ─► TRIVIAL (skip Doc Check, full review)        ║
    ║  • Typo fix (docs)    ─► TRIVIAL (skip Doc Check AND QA, full review) ║
    ║  • Config change      ─► TRIVIAL (single file, no behavior change)    ║
    ║  • Bug fix            ─► ASSESS (depends on scope)                    ║
    ║  • New feature        ─► COMPLEX (full workflow)                      ║
    ║  • Refactoring        ─► COMPLEX (regression risk)                    ║
    ║  • API change         ─► COMPLEX (breaking changes)                   ║
    ╚═══════════════════════════════════════════════════════════════════════╝

    NOTE: Workflow ENDS after successful review. Commit/PR are invoked
          separately via user commands (/command__commit, /command__pull-request).
```

## MCP Server Matrix

> **Note**: Short names refer to `@subagent/*` agents (e.g., "research" = `@subagent/research`).

| MCP Server      | research | task | code | qa  | commit | pull-request | document | devops | review | review-validation |
| --------------- | :------: | :--: | :--: | :-: | :----: | :----------: | :------: | :----: | :----: | :---------------: |
| `context7`      |    ✅    |  ❌  |  ✅  | ✅  |   ❌   |      ❌      |    ✅    |   ✅   |   ❌   |        ❌         |
| `aws-knowledge` |    ✅    |  ❌  |  ✅  | ✅  |   ❌   |      ❌      |    ✅    |   ✅   |   ❌   |        ❌         |
| `linear`        |    ✅    |  ❌  |  ❌  | ❌  |   ❌   |      ✅      |    ❌    |   ❌   |   ❌   |        ❌         |
| `atlassian`     |    ✅    |  ❌  |  ❌  | ❌  |   ❌   |      ✅      |    ❌    |   ❌   |   ❌   |        ❌         |
| `playwright`    |    ❌    |  ❌  |  ❌  | ✅  |   ❌   |      ❌      |    ❌    |   ❌   |   ❌   |        ❌         |

### Server Purposes

| Server          | Purpose                | Use Cases                               |
| --------------- | ---------------------- | --------------------------------------- |
| `context7`      | Library/framework docs | API lookups, best practices, examples   |
| `aws-knowledge` | AWS documentation      | Service configs, IAM policies, patterns |
| `linear`        | Issue tracking         | Link PRs to issues, check task status   |
| `atlassian`     | Jira/Confluence        | Link to Jira tickets, wiki references   |
| `playwright`    | Browser automation     | E2E testing, UI validation              |

## Tool Permission Matrix

### Built-in Tools

| Tool        | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| `bash`      | Execute shell commands                                       |
| `edit`      | Modify existing files using exact string replacements        |
| `write`     | Create new files or overwrite existing ones                  |
| `read`      | Read file contents                                           |
| `grep`      | Search file contents using regex                             |
| `glob`      | Find files by pattern matching                               |
| `list`      | List files and directories                                   |
| `patch`     | Apply patches to files                                       |
| `todowrite` | Manage todo lists (disabled for subagents by default)        |
| `todoread`  | Read existing todo lists (disabled for subagents by default) |
| `webfetch`  | Fetch web content                                            |

### Primary Agents Permissions

| Tool        | plan | dev |
| ----------- | :--: | :-: |
| `bash`      |  ❌  | ❌  |
| `edit`      |  ❌  | ❌  |
| `write`     |  ❌  | ❌  |
| `read`      |  ❌  | ❌  |
| `grep`      |  ❌  | ❌  |
| `glob`      |  ❌  | ❌  |
| `list`      |  ❌  | ❌  |
| `patch`     |  ❌  | ❌  |
| `todowrite` |  ✅  | ✅  |
| `todoread`  |  ✅  | ✅  |
| `webfetch`  |  ❌  | ❌  |
| MCP tools   |  ❌  | ❌  |

**Primary agents can ONLY directly use `todowrite` and `todoread`. ALL other tools must go through sub-agents.**

### Sub-Agents Permissions

> **Note**: Short names refer to `@subagent/*` agents (e.g., "research" = `@subagent/research`).

| Tool        | research | task | code | qa  | commit | pull-request | document | devops | review | review-validation |
| ----------- | :------: | :--: | :--: | :-: | :----: | :----------: | :------: | :----: | :----: | :---------------: |
| `bash`      |    ❌    |  ❌  |  ✅  | ✅  |   ❌   |      ❌      |    ❌    |   ✅   |   ❌   |        ❌         |
| `edit`      |    ❌    |  ❌  |  ✅  | ❌  |   ❌   |      ❌      |    ✅    |   ✅   |   ❌   |        ❌         |
| `write`     |    ❌    |  ❌  |  ✅  | ❌  |   ❌   |      ❌      |    ✅    |   ✅   |   ❌   |        ❌         |
| `read`      |    ✅    |  ✅  |  ✅  | ✅  |   ✅   |      ✅      |    ✅    |   ✅   |   ✅   |        ✅         |
| `grep`      |    ✅    |  ✅  |  ✅  | ✅  |   ✅   |      ✅      |    ✅    |   ✅   |   ✅   |        ✅         |
| `glob`      |    ✅    |  ✅  |  ✅  | ✅  |   ✅   |      ✅      |    ✅    |   ✅   |   ✅   |        ✅         |
| `list`      |    ✅    |  ✅  |  ✅  | ✅  |   ✅   |      ✅      |    ✅    |   ✅   |   ✅   |        ✅         |
| `patch`     |    ❌    |  ❌  |  ✅  | ❌  |   ❌   |      ❌      |    ✅    |   ✅   |   ❌   |        ❌         |
| `todowrite` |    ❌    |  ❌  |  ❌  | ❌  |   ❌   |      ❌      |    ❌    |   ❌   |   ❌   |        ❌         |
| `todoread`  |    ❌    |  ❌  |  ❌  | ❌  |   ❌   |      ❌      |    ❌    |   ❌   |   ❌   |        ❌         |
| `webfetch`  |    ✅    |  ❌  |  ❌  | ❌  |   ❌   |      ❌      |    ✅    |   ❌   |   ❌   |        ❌         |
| MCP tools   |    ✅    |  ❌  |  ✅  | ✅  |   ❌   |      ✅      |    ✅    |   ✅   |   ❌   |        ❌         |

### Custom Tools Permission Matrix

Custom tools from `tools__gh.ts` and `tools__git.ts` plugins replace hardcoded bash commands for safer operation.

| Tool                                          | commit | pull-request | review | review-validation |
| --------------------------------------------- | :----: | :----------: | :----: | :---------------: |
| `tool__gh--retrieve-pull-request-info`        |   ❌   |      ✅      |   ✅   |        ✅         |
| `tool__gh--retrieve-repository-collaborators` |   ❌   |      ✅      |   ❌   |        ❌         |
| `tool__gh--create-pull-request`               |   ❌   |      ✅      |   ❌   |        ❌         |
| `tool__gh--edit-pull-request`                 |   ❌   |      ✅      |   ❌   |        ❌         |
| `tool__git--retrieve-pull-request-diff`       |   ❌   |      ❌      |   ✅   |        ❌         |
| `tool__git--retrieve-latest-n-commits-diff`   |   ❌   |      ❌      |   ✅   |        ❌         |
| `tool__git--retrieve-current-branch-diff`     |   ✅   |      ✅      |   ✅   |        ❌         |
| `tool__git--status`                           |   ✅   |      ❌      |   ❌   |        ❌         |
| `tool__git--stage-files`                      |   ✅   |      ❌      |   ❌   |        ❌         |
| `tool__git--commit`                           |   ✅   |      ❌      |   ❌   |        ❌         |
| `tool__git--push`                             |   ❌   |      ✅      |   ❌   |        ❌         |

#### Custom Tool Purposes

| Tool                                          | Purpose                                                        | Type  |
| --------------------------------------------- | -------------------------------------------------------------- | ----- |
| `tool__gh--retrieve-pull-request-info`        | Fetch PR state, title, body, comments, reviews, review threads | Read  |
| `tool__gh--retrieve-repository-collaborators` | List repository collaborators for reviewer selection           | Read  |
| `tool__gh--create-pull-request`               | Create new pull request                                        | Write |
| `tool__gh--edit-pull-request`                 | Edit existing pull request                                     | Write |
| `tool__git--retrieve-pull-request-diff`       | Fetch diff of a GitHub PR                                      | Read  |
| `tool__git--retrieve-latest-n-commits-diff`   | Fetch diff of last N commits                                   | Read  |
| `tool__git--retrieve-current-branch-diff`     | Fetch diff of current branch vs main                           | Read  |
| `tool__git--status`                           | Retrieve git status (staged, unstaged, untracked files)        | Read  |
| `tool__git--stage-files`                      | Stage files for commit                                         | Write |
| `tool__git--commit`                           | Create a git commit with staged changes                        | Write |
| `tool__git--push`                             | Push current branch to remote repository                       | Write |

### Bash Permission Matrix (Granular)

Each agent has granular bash permissions configured via `permission.bash` in their YAML frontmatter, following the principle of least privilege.

#### Permission Levels

| Level   | Meaning                              |
| ------- | ------------------------------------ |
| `deny`  | Command is blocked                   |
| `allow` | Command runs without approval        |
| `ask`   | Command requires user approval first |

#### Primary Agents (Orchestrators)

All primary agents have `permission.bash: deny` - they delegate to sub-agents.

| Agent           | Bash Permission |
| --------------- | --------------- |
| `@primary/plan` | `deny`          |
| `@primary/dev`  | `deny`          |

#### Sub-Agents (Specialists)

| Agent                         | Default | Allowed Commands                                                                                                                                                                                          | Ask Commands                                  |
| ----------------------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| `@subagent/code`              | `deny`  | ls, pwd, cat, head, tail, find, npm/pnpm/yarn/bun, go, cargo, pip, poetry, make, eslint, prettier, tsc, git (read)                                                                                        | rm, mv                                        |
| `@subagent/commit`            | `deny`  | (none - uses custom tools)                                                                                                                                                                                | git push                                      |
| `@subagent/devops`            | `deny`  | ls, pwd, cat, head, tail, find, yamllint, hadolint, shellcheck, actionlint, terraform init/validate/fmt, aws validate, docker build/images/ps, git (read)                                                 | terraform plan/apply, docker run/push, rm, mv |
| `@subagent/document`          | `deny`  | (none)                                                                                                                                                                                                    | (none)                                        |
| `@subagent/pull-request`      | `deny`  | (none - uses custom tools)                                                                                                                                                                                | (none)                                        |
| `@subagent/qa`                | `deny`  | ls, pwd, cat, find, npm/pnpm/yarn/bun (full), eslint, tsc, jest, vitest, playwright, cypress, go (test/build/vet), golangci-lint, poetry run (pytest/ruff/mypy/pyright/build), coverage tools, git (read) | (none)                                        |
| `@subagent/research`          | `deny`  | (none)                                                                                                                                                                                                    | (none)                                        |
| `@subagent/review`            | `deny`  | (none - uses custom tools)                                                                                                                                                                                | (none)                                        |
| `@subagent/review-validation` | `deny`  | (none - uses custom tools)                                                                                                                                                                                | (none)                                        |
| `@subagent/task`              | `deny`  | (none)                                                                                                                                                                                                    | (none)                                        |

#### Configuration Reference

Bash permissions are configured in each agent's markdown file frontmatter:

```yaml
---
description: Agent description
mode: subagent
tools:
  bash: true
  # ... other tools
permission:
  bash:
    "*": deny
    "git status": allow
    "git push *": ask
---
```

See [OpenCode Permissions Documentation](https://opencode.ai/docs/permissions/#bash) for full syntax.

## Quick Reference

### Agent ID Reference

| Agent             | ID                            | Type    | Invocation                                     |
| ----------------- | ----------------------------- | ------- | ---------------------------------------------- |
| Plan              | `@primary/plan`               | Primary | User selection                                 |
| Dev               | `@primary/dev`                | Primary | User selection                                 |
| Research          | `@subagent/research`          | Sub     | Orchestrator                                   |
| Task              | `@subagent/task`              | Sub     | Orchestrator                                   |
| Code              | `@subagent/code`              | Sub     | Orchestrator                                   |
| QA                | `@subagent/qa`                | Sub     | Orchestrator                                   |
| Commit            | `@subagent/commit`            | Sub     | **Command only** (`/command__commit`)          |
| Pull Request      | `@subagent/pull-request`      | Sub     | **Command only** (`/command__pull-request`)    |
| Document          | `@subagent/document`          | Sub     | Orchestrator                                   |
| DevOps            | `@subagent/devops`            | Sub     | Orchestrator                                   |
| Review            | `@subagent/review`            | Sub     | Orchestrator or `/command__review`             |
| Review Validation | `@subagent/review-validation` | Sub     | **Command only** (`/command__validate-review`) |

### Mode Reference

| Mode          | Applies To           | Description                                  |
| ------------- | -------------------- | -------------------------------------------- |
| Draft Mode    | commit, pull-request | Analyze and propose                          |
| Apply Mode    | commit, pull-request | Perform operation                            |
| Draft Mode    | document             | Propose without applying                     |
| Research Mode | research             | Structured findings for planning             |
| Question Mode | research             | Conversational answers (no workflow trigger) |

### Phase Reference (Dev)

| Phase     | Description                                                                       | Conditional?                                                         |
| --------- | --------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| Phase 1   | Work (code, document, or devops) - supports parallel execution for isolated items | Always                                                               |
| Phase 2   | Documentation Check                                                               | Skip if work_agent(s) is document only                               |
| Phase 2.5 | QA/Testing                                                                        | Skip if work_agent(s) is document only; validates all parallel items |
| Phase 3   | Parallel Review (4x)                                                              | Always                                                               |
| Phase 4   | Issue Resolution                                                                  | Always                                                               |

### Status Reference

| Status                | Meaning                      |
| --------------------- | ---------------------------- |
| `success`             | Task completed successfully  |
| `partial`             | Task partially completed     |
| `failure`             | Task failed                  |
| `waiting_approval`    | Awaiting user decision       |
| `needs_fixes`         | Issues found requiring fixes |
| `needs_clarification` | Insufficient information     |

### Severity Reference

| Severity         | Icon | Action Required            |
| ---------------- | ---- | -------------------------- |
| Critical         |      | Must fix before proceeding |
| Major/Warning    |      | Should fix                 |
| Minor/Suggestion |      | Nice to have               |
