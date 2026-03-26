# File Templates

MD templates for task breakdown output files. All files go in `__docs/task/`.

## Main File: `__docs/task/<feature>__main.md`

````md
---
title: "<Feature Name> — Task Plan"
feature: "<feature-name>"
total_tasks: <N>
total_estimated_time: "<range>"
status: "planned"
---

# <Feature Name> — Task Plan

## Summary

<1-2 sentence summary of what this plan accomplishes and the overall approach.>

## Tasks

**Total Tasks**: <N>
**Total Estimated Time**: <sum of estimates>

| #   | Task    | Agent     | Complexity   | Time   | Link                                |
| --- | ------- | --------- | ------------ | ------ | ----------------------------------- |
| 1   | <title> | `<agent>` | <complexity> | <time> | [<title>](./<feature>__task-001.md) |
| 2   | <title> | `<agent>` | <complexity> | <time> | [<title>](./<feature>__task-002.md) |
| ... | ...     | ...       | ...          | ...    | ...                                 |

## Execution Plan

```dot
<DOT_DIGRAPH — see references/digraph.md for specification>
```

## Risks

- <risk 1: what could go wrong and impact>
- <risk 2: what could go wrong and impact>

## Recommendations

- <recommendation 1: suggestion for execution>
- <recommendation 2: suggestion for execution>
````

### Main File Rules

- The frontmatter `status` field is always `"planned"` when first created
- The tasks table MUST list every task in execution order
- The DOT digraph MUST match the tasks table exactly (same IDs, same dependencies)
- Risks should be specific to this plan, not generic ("tests might fail" is too vague)
- Recommendations should be actionable ("Run Task 3 before Task 2 if the email service is slow to provision")

## Per-Task File: `__docs/task/<feature>__task-<NNN>.md`

````md
---
title: "Task <N>: <Title>"
feature: "<feature-name>"
task_number: <N>
complexity: "<trivial|simple|moderate|complex>"
agent: "<agent string>"
dependencies: [<list of task numbers>]
status: "planned"
---

# Task <N>: <Title>

## Description

<Detailed description of what this task accomplishes. Be specific about:

- What files are created or modified
- What behavior changes
- What the end state looks like>

## Dependencies

<List dependencies or "None">

- Task <X>: <reason this must complete first>

## Estimated Time

<time range> (<complexity level>)

## Acceptance Criteria

- [ ] <criterion 1 — specific, measurable, verifiable>
- [ ] <criterion 2>
- [ ] <criterion 3>

## Pseudo Code

```<language>
<pseudo code written in the project's actual programming language(s) showing the implementation approach>
```

## Files Affected

- `<path/to/file1>` — <what changes>
- `<path/to/file2>` — <what changes>
````

### Per-Task File Rules

- **Task numbers** are zero-padded to 3 digits: 001, 002, ..., 999
- **Dependencies** in frontmatter use task numbers only: `[1, 3]` means depends on Task 1 and Task 3
- **Acceptance criteria** MUST be checkboxes (`- [ ]`) — they serve as a completion checklist
- **Pseudo code** MUST use the project's actual language. Detect from: file extensions in the repo, package.json/pyproject.toml/Cargo.toml, existing source files. If the project uses TypeScript, write TypeScript. If Python, write Python.
- **Files Affected** lists the specific files this task will create or modify. This helps the executing agent scope its work.
- **Status** starts as `"planned"` and can be updated to `"in-progress"`, `"done"`, or `"blocked"`

### Complexity-to-Time Alignment

The `estimated_time` MUST align with `complexity`:

| Complexity | Valid Time Ranges                                        |
| ---------- | -------------------------------------------------------- |
| trivial    | "5 min", "15 min", "< 30 min"                            |
| simple     | "30 min - 1 hr", "1-2 hrs"                               |
| moderate   | "2-4 hrs", "4-6 hrs", "2-8 hrs"                          |
| complex    | "8+ hrs" — but this should trigger further decomposition |
