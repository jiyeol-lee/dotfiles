# Multi-Agent System Reference

## Table of Contents

1. [Agent Summary](#agent-summary)
2. [Directory Structure](#directory-structure)
3. [Agent Relationship Diagrams](#agent-relationship-diagrams)
4. [Agent Invocation Reference](#agent-invocation-reference)
5. [Workflow Diagrams](#workflow-diagrams)
6. [Review Logic](#review-logic)
7. [MCP Server Matrix](#mcp-server-matrix)
8. [Tool Permission Matrix](#tool-permission-matrix)
9. [Skills System](#skills-system)
10. [Quick Reference](#quick-reference)
11. [Model Tier Recommendations](#model-tier-recommendations)

## Agent Summary

| Type    | Agent                        | Role                                                           |
| ------- | ---------------------------- | -------------------------------------------------------------- |
| Primary | `primary/plan`               | Research and task planning orchestrator                        |
| Primary | `primary/build`              | Development workflow orchestrator                              |
| Sub     | `subagent/research`          | Information gathering                                          |
| Sub     | `subagent/task`              | Task breakdown and planning                                    |
| Sub     | `subagent/code`              | Code implementation                                            |
| Sub     | `subagent/e2e-test`          | E2E testing specialist (Playwright), writes and runs E2E tests |
| Sub     | `subagent/check`             | Validation specialist (lint, type-check, format, tests)        |
| Sub     | `subagent/commit`            | Git commits (Draft/Apply Mode)                                 |
| Sub     | `subagent/pull-request`      | PR management (Draft/Apply Mode)                               |
| Sub     | `subagent/document`          | Documentation (Draft Mode)                                     |
| Sub     | `subagent/devops`            | DevOps and infrastructure                                      |
| Sub     | `subagent/review`            | Code review (scoped; single focus area per invocation)         |
| Sub     | `subagent/review-validation` | Validates PR review comment accuracy against actual code       |

## Directory Structure

```
.opencode/
├── AGENTS.md                           # Global rules (existing)
├── opencode.json                       # Configuration (existing)
│
├── agent/
│   ├── primary/                        # Primary agents (orchestrators)
│   │   ├── plan.md                     # primary/plan
│   │   └── build.md                    # primary/build
│   │
│   └── subagent/                       # Sub-agents (specialists)
│       ├── research.md                 # subagent/research
│       ├── task.md                     # subagent/task
│       ├── code.md                     # subagent/code
│       ├── e2e-test.md                 # subagent/e2e-test
│       ├── check.md                    # subagent/check
│       ├── commit.md                   # subagent/commit
│       ├── pull-request.md             # subagent/pull-request
│       ├── document.md                 # subagent/document
│       ├── devops.md                   # subagent/devops
│       ├── review.md                   # subagent/review
│       └── review-validation.md        # subagent/review-validation
│
├── command/                            # Commands
│   ├── command__commit.md              # Shortcut for commit workflow
│   ├── command__pull-request.md        # Shortcut for PR workflow
│   ├── command__review.md              # Shortcut for code review
│   └── command__validate-review.md     # Shortcut for PR review validation
│
├── plugin/                             # Plugins
│   ├── notifications.ts
│   ├── tools__gh.ts
│   └── tools__git.ts
│
├── skill/                              # Skills (reusable knowledge modules)
│   └── code-review/
│       ├── SKILL.md
│       └── references/
│           ├── quality.md
│           ├── regression.md
│           ├── documentation.md
│           └── performance.md
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
│         primary/plan            │       │          primary/build          │
│                                 │       │                                 │
│   (Research & Planning)         │       │   (Development Workflow)        │
└────────────────┬────────────────┘       └────────────────┬────────────────┘
                 │                                         │
                 ▼                                         ▼
┌───────────────────────────────────────────────┐   ┌───────────────────────────────────────────────────────────────────────────┐
│              PLANNING SUB-AGENTS              │   │                          DEVELOPMENT SUB-AGENTS                           │
│         (Dedicated to primary/plan)           │   │                         (Used by primary/build)                           │
├───────────────────────────────────────────────┤   ├───────────────────────────────────────────────────────────────────────────┤
│                                               │   │                                                                           │
│  ┌────────────────────┐  ┌────────────────┐   │   │  ┌────────────────┐  ┌───────────────────┐  ┌────────────────────┐        │
│  │ subagent/research  │  │ subagent/task  │   │   │  │ subagent/code  │  │ subagent/e2e-test │  │ subagent/document  │        │
│  └────────────────────┘  └────────────────┘   │   │  └────────────────┘  └───────────────────┘  └────────────────────┘        │
│                                               │   │                                                                           │
│                                               │   │  ┌─────────────────┐ ┌──────────────────┐  ┌───────────────────┐          │
│                                               │   │  │ subagent/check  │ │ subagent/devops  │  │ subagent/review*  │          │
│                                               │   │  └─────────────────┘ └──────────────────┘  └───────────────────┘          │
│                                               │   │                                                                           │
│                                               │   │  * review also available via /command__review                             │
└───────────────────────────────────────────────┘   └───────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           COMMAND-TRIGGERED SUB-AGENTS                              │
│        (Invoked ONLY via user commands - NOT by orchestrators)                      │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│    ┌────────────────────────────────────┐    ┌────────────────────────────────────┐ │
│    │      subagent/commit               │    │      subagent/pull-request         │ │
│    │                                    │    │                                    │ │
│    │      /command__commit              │    │      /command__pull-request        │ │
│    └────────────────────────────────────┘    └────────────────────────────────────┘ │
│                                                                                     │
│    ┌────────────────────────────────────┐                                           │
│    │      subagent/review-validation    │                                           │
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

- `primary/plan` has its own dedicated sub-agents (`subagent/research`, `subagent/task`) and does NOT use development sub-agents
- `primary/build` uses the development sub-agents (`subagent/code`, `subagent/e2e-test`, `subagent/check`, `subagent/document`, `subagent/devops`, `subagent/review`)
- Sub-agents never call other sub-agents; they only report to their orchestrator
- `subagent/commit` and `subagent/pull-request` are ONLY invoked via commands (`/command__commit`, `/command__pull-request`)
- `subagent/review` is invoked by orchestrators AND available via `/command__review` command

### Parallel Execution in Phase 1

`primary/build` supports parallel sub-agent execution in Phase 1 when work items are **isolated**:

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

| Agent                        | Command                     | Flow                               |
| ---------------------------- | --------------------------- | ---------------------------------- |
| `subagent/commit`            | `/command__commit`          | Draft Mode → Approval → Apply Mode |
| `subagent/pull-request`      | `/command__pull-request`    | Draft Mode → Approval → Apply Mode |
| `subagent/review-validation` | `/command__validate-review` | Fetch → Analyze → Report           |

### Orchestrator-Invoked (also available via command)

| Agent             | Invoked By                                 |
| ----------------- | ------------------------------------------ |
| `subagent/review` | Orchestrator OR `/command__review` command |

### Orchestrator-Invoked Only

These agents are invoked by primary agents as part of workflows:

| Agent               | Used By             |
| ------------------- | ------------------- |
| `subagent/research` | `primary/plan` only |
| `subagent/task`     | `primary/plan` only |
| `subagent/code`     | `primary/build`     |
| `subagent/e2e-test` | `primary/build`     |
| `subagent/check`    | `primary/build`     |
| `subagent/document` | `primary/build`     |
| `subagent/devops`   | `primary/build`     |

## Workflow Diagrams

### Plan Agent Workflow

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                              primary/plan                                     │
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
    │    subagent/      │                           │    subagent/      │
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
                          │        primary/plan           │
                          └───────────────────────────────┘
                                        │
                                        │ 3. Delegate task breakdown
                                        ▼
                              ┌───────────────────┐
                              │    subagent/      │
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

### Build Agent Workflow

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                             primary/build                                     │
│                       (Development Workflow)                                  │
└───────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        │ Receive development task
                                        ▼
                          ┌───────────────────────────────┐
                          │    SIMPLE DELEGATOR MODEL     │
                          │                               │
                          │    primary/build delegates    │
                          │    to appropriate sub-agents  │
                          │    based on task type         │
                          └───────────────────────────────┘
                                        │
                                        │ Phase 1: Work (may be parallel)
          ┌───────────────────┬─────────┴──────────────┬───────────────────┐
          ▼                   ▼                        ▼                   ▼
┌───────────────────┐ ┌───────────────────┐ ┌───────────────────┐ ┌───────────────────┐
│  subagent/code    │ │ subagent/e2e-test │ │subagent/document  │ │ subagent/devops   │
│                   │ │                   │ │                   │ │                   │
│  Implementation   │ │  E2E Testing      │ │  Documentation    │ │  Infrastructure   │
│  Bug fixes        │ │  Playwright tests │ │  User-facing docs │ │  CI/CD, Docker    │
│  Refactoring      │ │  UI validation    │ │  Internal docs    │ │  IaC configs      │
└─────────┬─────────┘ └────────┬──────────┘ └─────────┬─────────┘ └─────────┬─────────┘
          └────────────────────┴──────────┬───────────┴─────────────────────┘
                                          │
                                          ▼
                          ┌───────────────────────────────┐
                          │ Phase 2: Validation (check)   │
                          │   subagent/check              │
                          │   • lint / format             │
                          │   • type-check / tests        │
                          │   (skipped for document-only) │
                          └───────────────┬───────────────┘
                                          │
                                          ▼
                          ┌────────────────────────────────┐
                          │ Phase 3: Review (CONDITIONAL)  │
                          │ Review runs only when:         │
                          │   • user requests review       │
                          │   • user requests specific     │
                          │     review scopes              │
                          │   • build recommends review    │
                          │     and user approves          │
                          └───────────────┬────────────────┘
                         ┌────────────────┴──────────────┐
                         │                               │
                     YES ▼                               ▼ NO
       ┌───────────────────────────────────┐   ┌─────────────────────┐
       │ subagent/review (scoped)          │   │   Report to User    │
       │ (single focus area per invocation)│   └─────────────────────┘
       └──────────────────┬────────────────┘
                          │
                          ▼
          ┌───────────────────────────────┐
          │ Phase 4: Issue Resolution     │
          │ (only if review finds issues) │
          └───────────────┬───────────────┘
                          │
                          ▼
          ┌───────────────────────────────┐
          │       Report to User          │
          └───────────────────────────────┘

    NOTE: Review is optional and does not run automatically.
          If the user requests "run review" (general), build runs all 4 scopes.
          Commit/PR are invoked separately via user commands (/command__commit, /command__pull-request).
```

### Review Logic

`primary/build` treats `subagent/review` as an **optional** phase. Each invocation covers a **single focus area**; multiple scopes require multiple invocations (optionally parallel). Review scope selection follows these rules:

1. **User instructs "run review" (general)**
   - Run **all 4** scopes: **quality**, **regression**, **documentation**, **performance**.
   - Invoke `subagent/review` **once per scope** (4 invocations).

2. **User instructs specific scope(s)**
   - Run **only** the explicitly requested scope(s).
   - Invoke `subagent/review` **once per scope** (N invocations).

3. **Build recommends review**
   - Build recommends scope(s) based on the changes.
   - Build asks for user approval.
   - Build runs **only** the approved scope(s) (otherwise review is skipped).
   - Invoke `subagent/review` **once per approved scope**.

If none of the above applies, build skips review entirely.

## MCP Server Matrix

> **Note**: Short names refer to `subagent/*` agents (e.g., "research" = `subagent/research`).

| MCP Server      | research | task | code | e2e-test | check | commit | pull-request | document | devops | review | review-validation |
| --------------- | :------: | :--: | :--: | :------: | :---: | :----: | :----------: | :------: | :----: | :----: | :---------------: |
| `context7`      |    ✅    |  ❌  |  ✅  |    ✅    |  ❌   |   ❌   |      ❌      |    ✅    |   ✅   |   ❌   |        ❌         |
| `aws-knowledge` |    ✅    |  ❌  |  ✅  |    ❌    |  ❌   |   ❌   |      ❌      |    ✅    |   ✅   |   ❌   |        ❌         |
| `linear`        |    ✅    |  ❌  |  ❌  |    ❌    |  ❌   |   ❌   |      ✅      |    ❌    |   ❌   |   ❌   |        ❌         |
| `atlassian`     |    ✅    |  ❌  |  ❌  |    ❌    |  ❌   |   ❌   |      ✅      |    ❌    |   ❌   |   ❌   |        ❌         |
| `playwright`    |    ❌    |  ❌  |  ❌  |    ✅    |  ❌   |   ❌   |      ❌      |    ❌    |   ❌   |   ❌   |        ❌         |

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

| Tool        | plan | build |
| ----------- | :--: | :---: |
| `bash`      |  ❌  |  ❌   |
| `edit`      |  ❌  |  ❌   |
| `write`     |  ❌  |  ❌   |
| `read`      |  ❌  |  ❌   |
| `grep`      |  ❌  |  ❌   |
| `glob`      |  ❌  |  ❌   |
| `list`      |  ❌  |  ❌   |
| `patch`     |  ❌  |  ❌   |
| `todowrite` |  ✅  |  ✅   |
| `todoread`  |  ✅  |  ✅   |
| `webfetch`  |  ❌  |  ❌   |
| MCP tools   |  ❌  |  ❌   |

**Primary agents can ONLY directly use `todowrite` and `todoread`. ALL other tools must go through sub-agents.**

### Sub-Agents Permissions

> **Note**: Short names refer to `subagent/*` agents (e.g., "research" = `subagent/research`).

| Tool        | research | task | code | e2e-test | check | commit | pull-request | document | devops | review | review-validation |
| ----------- | :------: | :--: | :--: | :------: | :---: | :----: | :----------: | :------: | :----: | :----: | :---------------: |
| `bash`      |    ❌    |  ❌  |  ✅  |    ✅    |  ✅   |   ❌   |      ❌      |    ❌    |   ✅   |   ❌   |        ❌         |
| `edit`      |    ❌    |  ❌  |  ✅  |    ✅    |  ❌   |   ❌   |      ❌      |    ✅    |   ✅   |   ❌   |        ❌         |
| `write`     |    ❌    |  ❌  |  ✅  |    ✅    |  ❌   |   ❌   |      ❌      |    ✅    |   ✅   |   ❌   |        ❌         |
| `read`      |    ✅    |  ✅  |  ✅  |    ✅    |  ✅   |   ✅   |      ✅      |    ✅    |   ✅   |   ✅   |        ✅         |
| `grep`      |    ✅    |  ✅  |  ✅  |    ✅    |  ✅   |   ✅   |      ✅      |    ✅    |   ✅   |   ✅   |        ✅         |
| `glob`      |    ✅    |  ✅  |  ✅  |    ✅    |  ✅   |   ✅   |      ✅      |    ✅    |   ✅   |   ✅   |        ✅         |
| `list`      |    ✅    |  ✅  |  ✅  |    ✅    |  ✅   |   ✅   |      ✅      |    ✅    |   ✅   |   ✅   |        ✅         |
| `patch`     |    ❌    |  ❌  |  ✅  |    ✅    |  ❌   |   ❌   |      ❌      |    ✅    |   ✅   |   ❌   |        ❌         |
| `todowrite` |    ❌    |  ❌  |  ❌  |    ❌    |  ❌   |   ❌   |      ❌      |    ❌    |   ❌   |   ❌   |        ❌         |
| `todoread`  |    ❌    |  ❌  |  ❌  |    ❌    |  ❌   |   ❌   |      ❌      |    ❌    |   ❌   |   ❌   |        ❌         |
| `webfetch`  |    ✅    |  ❌  |  ❌  |    ❌    |  ❌   |   ❌   |      ❌      |    ✅    |   ❌   |   ❌   |        ❌         |
| MCP tools   |    ✅    |  ❌  |  ✅  |    ✅    |  ❌   |   ❌   |      ✅      |    ✅    |   ✅   |   ❌   |        ❌         |

### Custom Tools Permission Matrix

Custom tools from `tools__gh.ts` and `tools__git.ts` plugins replace hardcoded bash commands for safer operation.

| Tool                                              | commit | pull-request | review | review-validation | research |
| ------------------------------------------------- | :----: | :----------: | :----: | :---------------: | :------: |
| `tool__gh--retrieve-pull-request-info`            |   ❌   |      ✅      |   ✅   |        ✅         |    ✅    |
| `tool__gh--retrieve-repository-collaborators`     |   ❌   |      ✅      |   ❌   |        ❌         |    ❌    |
| `tool__gh--create-pull-request`                   |   ❌   |      ✅      |   ❌   |        ❌         |    ❌    |
| `tool__gh--edit-pull-request`                     |   ❌   |      ✅      |   ❌   |        ❌         |    ❌    |
| `tool__gh--retrieve-pull-request-diff`            |   ❌   |      ❌      |   ✅   |        ❌         |    ✅    |
| `tool__gh--retrieve-repository-dependabot-alerts` |   ❌   |      ❌      |   ✅   |        ❌         |    ✅    |
| `tool__git--retrieve-latest-n-commits-diff`       |   ❌   |      ❌      |   ✅   |        ❌         |    ❌    |
| `tool__git--retrieve-current-branch-diff`         |   ✅   |      ✅      |   ✅   |        ❌         |    ✅    |
| `tool__git--status`                               |   ✅   |      ❌      |   ❌   |        ❌         |    ❌    |
| `tool__git--stage-files`                          |   ✅   |      ❌      |   ❌   |        ❌         |    ❌    |
| `tool__git--commit`                               |   ✅   |      ❌      |   ❌   |        ❌         |    ❌    |
| `tool__git--push`                                 |   ❌   |      ✅      |   ❌   |        ❌         |    ❌    |

#### Custom Tool Purposes

| Tool                                          | Purpose                                                        | Type  |
| --------------------------------------------- | -------------------------------------------------------------- | ----- |
| `tool__gh--retrieve-pull-request-info`        | Fetch PR state, title, body, comments, reviews, review threads | Read  |
| `tool__gh--retrieve-repository-collaborators` | List repository collaborators for reviewer selection           | Read  |
| `tool__gh--create-pull-request`               | Create new pull request                                        | Write |
| `tool__gh--edit-pull-request`                 | Edit existing pull request                                     | Write |
| `tool__gh--retrieve-pull-request-diff`        | Fetch diff of a GitHub PR                                      | Read  |
| `tool__git--retrieve-latest-n-commits-diff`   | Fetch diff of last N commits                                   | Read  |
| `tool__git--retrieve-current-branch-diff`     | Fetch diff of current branch vs main                           | Read  |
| `tool__git--status`                           | Retrieve git status (staged, unstaged, untracked files)        | Read  |
| `tool__git--stage-files`                      | Stage files for commit                                         | Write |
| `tool__git--commit`                           | Create a git commit with staged changes                        | Write |
| `tool__git--push`                             | Push current branch to remote repository                       | Write |

### Bash Permission Matrix (Granular)

Some agents have granular bash permissions configured via `permission.bash` in their YAML frontmatter (least privilege). Agents without a per-agent allowlist (e.g. `subagent/check`) rely on default OpenCode permissions, but are constrained by role (validation only).

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
| `primary/plan`  | `deny`          |
| `primary/build` | `deny`          |

#### Sub-Agents (Specialists)

| Agent                        | Default | Allowed Commands                                                            | Ask Commands |
| ---------------------------- | ------- | --------------------------------------------------------------------------- | ------------ |
| `subagent/code`              | `ask`   | `rg *, cat *, head *, tail *, ls *, echo *, wc *, git status *, git diff *` | `(other)`    |
| `subagent/commit`            | `deny`  | (none - uses custom tools)                                                  | (none)       |
| `subagent/devops`            | `ask`   | `rg *, cat *, head *, tail *, ls *, echo *, wc *, git status *, git diff *` | `(other)`    |
| `subagent/document`          | `deny`  | (none)                                                                      | (none)       |
| `subagent/e2e-test`          | `deny`  | `yarn run test:e2e *`, `npm run test:e2e *`                                 | (none)       |
| `subagent/check`             | `allow` | (all)                                                                       | (none)       |
| `subagent/pull-request`      | `deny`  | (none - uses custom tools)                                                  | (none)       |
| `subagent/research`          | `deny`  | (none - uses custom tools)                                                  | (none)       |
| `subagent/review`            | `deny`  | (none - uses custom tools)                                                  | (none)       |
| `subagent/review-validation` | `deny`  | (none - uses custom tools)                                                  | (none)       |
| `subagent/task`              | `deny`  | (none)                                                                      | (none)       |

#### Configuration Reference

Bash permissions can be configured in an agent's markdown file frontmatter (optional):

**Simple Pattern** (block by default, allow specific):

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
    "git status *": allow
    "git push *": ask
---
```

Use this pattern when you want to block most commands by default and only allow specific safe commands.

**Granular Pattern** (ask by default, pre-approve safe commands):

```yaml
---
description: Agent with granular bash permissions
mode: subagent
tools:
  bash: true
permission:
  bash:
    "*": ask # All commands require approval by default
    "rg *": allow
    "cat *": allow
    "head *": allow
    "tail *": allow
    "ls *": allow
    "echo *": allow
    "wc *": allow
    "git status": allow
    "git diff": allow
---
```

This granular pattern is used by `subagent/code.md` and `subagent/devops.md` to allow safe read-only commands while requiring explicit approval for all other operations. Use this pattern when you want most commands to require approval, but want to pre-approve a specific set of safe, read-only commands.

See [OpenCode Permissions Documentation](https://opencode.ai/docs/permissions/#bash) for full syntax.

## Skills System

Skills are reusable knowledge modules that agents can load on-demand. They externalize domain-specific guidelines, checklists, and reference materials from agent prompts.

### Structure

```
skill/<skill-name>/
├── SKILL.md                    # Entry point (frontmatter + overview)
└── references/                 # Detailed reference materials
    └── *.md
```

### Available Skills

| Skill         | Description                                                           | Used By           |
| ------------- | --------------------------------------------------------------------- | ----------------- |
| `code-review` | Review checklists for quality, regression, documentation, performance | `subagent/review` |

### Skill Permissions

Agents must have explicit permission to load skills. Configure in agent frontmatter:

```yaml
permission:
  skill:
    code-review: allow
```

Permission values: `allow`, `deny`, `ask`

### How Agents Load Skills

1. Agent load SKILL.md
2. Agent reads specific reference files based on task (e.g., `references/quality.md`)
3. Skill content provides checklists and output format guidance

## Quick Reference

### Agent ID Reference

| Agent             | ID                           | Type    | Invocation                                     |
| ----------------- | ---------------------------- | ------- | ---------------------------------------------- |
| Plan              | `primary/plan`               | Primary | User selection                                 |
| Build             | `primary/build`              | Primary | User selection                                 |
| Research          | `subagent/research`          | Sub     | Orchestrator                                   |
| Task              | `subagent/task`              | Sub     | Orchestrator                                   |
| Code              | `subagent/code`              | Sub     | Orchestrator                                   |
| E2E Test          | `subagent/e2e-test`          | Sub     | Orchestrator                                   |
| Check             | `subagent/check`             | Sub     | Orchestrator                                   |
| Commit            | `subagent/commit`            | Sub     | **Command only** (`/command__commit`)          |
| Pull Request      | `subagent/pull-request`      | Sub     | **Command only** (`/command__pull-request`)    |
| Document          | `subagent/document`          | Sub     | Orchestrator                                   |
| DevOps            | `subagent/devops`            | Sub     | Orchestrator                                   |
| Review            | `subagent/review`            | Sub     | Orchestrator or `/command__review`             |
| Review Validation | `subagent/review-validation` | Sub     | **Command only** (`/command__validate-review`) |

### Mode Reference

| Mode          | Applies To           | Description                                  |
| ------------- | -------------------- | -------------------------------------------- |
| Draft Mode    | commit, pull-request | Analyze and propose                          |
| Apply Mode    | commit, pull-request | Perform operation                            |
| Draft Mode    | document             | Propose without applying                     |
| Research Mode | research             | Structured findings for planning             |
| Question Mode | research             | Conversational answers (no workflow trigger) |

### Phase Reference (Build)

| Phase   | Description                                                                              | Conditional?                                       |
| ------- | ---------------------------------------------------------------------------------------- | -------------------------------------------------- |
| Phase 1 | Work (code, document, devops, e2e-test) - supports parallel execution for isolated items | Always                                             |
| Phase 2 | Validation (check)                                                                       | Skip if work_agent(s) is document only             |
| Phase 3 | Review (scoped; single focus area per invocation)                                        | Conditional (see [Review Logic](#review-logic))    |
| Phase 4 | Issue Resolution                                                                         | Conditional (only if review runs and finds issues) |

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

## Model Tier Recommendations

Recommendations for which model tier to use for each sub-agent based on task complexity.

### Tier Categories

| Tier         | Model Class               | Characteristics                                           |
| ------------ | ------------------------- | --------------------------------------------------------- |
| 💰 Cheap     | haiku-class / small_model | Deterministic tasks, structured output, minimal reasoning |
| 💵 Medium    | sonnet-class              | Moderate creativity, templated patterns, synthesis        |
| 💎 Expensive | opus-class / reasoning    | Complex reasoning, architecture decisions, deep analysis  |

### Sub-Agent Recommendations

| Sub-Agent                    | Tier         | Reasoning                                                                                   |
| ---------------------------- | ------------ | ------------------------------------------------------------------------------------------- |
| `subagent/commit`            | 💰 Cheap     | Follows strict Conventional Commits format. Input=diff, output=message. Minimal creativity. |
| `subagent/check`             | 💰 Cheap     | Executes predefined commands, parses output, reports results. No code generation.           |
| `subagent/task`              | 💰 Cheap     | Structured decomposition using templates. Highly structured JSON output.                    |
| `subagent/document`          | 💵 Medium    | Writes docs with moderate creativity but follows established patterns.                      |
| `subagent/devops`            | 💵 Medium    | Creates config files from known patterns. Docker, CI/CD, IaC are mostly templated.          |
| `subagent/pull-request`      | 💵 Medium    | Summarizes changes, writes PR descriptions. Synthesis without deep reasoning.               |
| `subagent/review-validation` | 💵 Medium    | Compares claims against code. Pattern matching with evidence gathering.                     |
| `subagent/e2e-test`          | 💵 Medium    | Writes E2E tests following Playwright patterns. More structured than app code.              |
| `subagent/code`              | 💎 Expensive | Writes production code, architecture decisions, debugging. Deep reasoning needed.           |
| `subagent/research`          | 💎 Expensive | Analyzes codebases, synthesizes from multiple sources. Deep analytical reasoning.           |
| `subagent/review`            | 💎 Expensive | Evaluates quality, identifies regressions, security, performance. Expert judgment.          |

> **Note**: These are recommendations only. Model selection can be configured per-agent in `opencode.json`.
