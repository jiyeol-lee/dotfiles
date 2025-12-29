---
name: code-review
description: |
  Code review guidelines for commits and file changes. Covers four categories:
  Quality (security, correctness, maintainability), Regression (breaking changes,
  API compatibility), Documentation (code docs, changelogs), and Performance
  (optimization, efficiency).
---

## Categories

| Category      | Reference                                    | Focus                                  |
| ------------- | -------------------------------------------- | -------------------------------------- |
| Quality       | [quality](references/quality.md)             | Security, correctness, maintainability |
| Regression    | [regression](references/regression.md)       | Breaking changes, API compatibility    |
| Documentation | [documentation](references/documentation.md) | Code docs, changelogs, API specs       |
| Performance   | [performance](references/performance.md)     | Optimization, efficiency               |

## Severity Levels

| Level      | Icon | Criteria                         | Action     |
| ---------- | ---- | -------------------------------- | ---------- |
| Critical   | 🔴   | Security, data loss, outage risk | Must fix   |
| Warning    | 🟡   | Bugs, bad practices              | Should fix |
| Suggestion | 🔵   | Improvements                     | Consider   |
