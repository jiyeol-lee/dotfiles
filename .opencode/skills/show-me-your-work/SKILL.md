---
name: show-me-your-work
description: Keeps a decision log, one TSV row per decision with its evidence, and gets it reviewed by another model before hand-back. Use for long-running or unattended work whose decisions the user will audit afterwards.
metadata:
  opencode/autoinvoke: false
---

# Show me your work

Keep one decision log per task.

## Where it lives

`$XDG_DATA_HOME/agentic-coding-tool/<slug>/decisions.tsv`, where `<slug>` names the task. Copy it into the repository only when a reviewer needs it, and say so in the PR.

## Format

One TSV file, one row per decision, every cell on one line. Columns:

- **ts**: ISO 8601 timestamp.
- **phase**: the phase, unit, or attempt.
- **decision**: what was chosen or done, in one line.
- **why**: the reason in plain words.
- **evidence**: a pointer that proves it, such as a commit SHA, a PR number, `file:line`, or an artifact path. Never a paragraph.
- **result**: the outcome, such as `tests pass`, `reverted`, `VERIFIED`, `INCONCLUSIVE`, or `open`.

Example:

```
ts	phase	decision	why	evidence	result
2026-11-18T09:02:00Z	frame	counted the callers first: 40 files, 6 packages	wanted the size before a long run	scripts/count-callers.sh	found 2 blockers
2026-11-18T09:40:00Z	harness	recorded every endpoint response before any change	to compare old against new	baseline/responses.json	saved 120 responses
2026-11-18T11:15:00Z	orders	moved orders to the new parser	smallest unit that lands alone	commit 7c21e0a	responses identical, tests pass
2026-11-18T12:30:00Z	orders	threw out a delegate's work because its test never ran	checked the test output instead of its summary	worktree reset	reverted, brief tightened
```

In a measured loop, such as the Hillclimb playbook, each attempt is a row: the attempt id as the phase, the hypothesis and change as the decision, the metric before and after with its delta and the commit as the evidence, and kept or reverted with the test result as the result.

```
ts	phase	decision	why	evidence	result
2026-11-18T14:05:00Z	attempt-3	index stock by name with a map instead of scanning a slice	the profile spends 97% of samples in the slice scan	p95 16.8ms to 8.6ms, -49%, commit 3291040	kept, tests pass
2026-11-18T14:40:00Z	attempt-4	reuse the JSON encoder across requests	encoding showed 6% of samples	p95 8.6ms to 8.5ms, -1%, within noise	reverted, tests pass
```

## Logging a row

Append one line per row with your edit or write tool. When the file is new, write the header line first. Separate cells with a single tab, and keep tabs and newlines out of every cell. Use the current UTC time for `ts`.

Write each row the way you would tell a teammate what you did. Log decision points, not every action: a fork chosen, a unit finished with its result, a pivot or revert and what triggered it, a blocker found, a check fixed. In a loop, log one row per iteration.

## Rules

- **Append only.** A wrong call gets a new row that supersedes it. Never edit or delete a row.
- **Prefer evidence from committed scripts** over one-off commands.

## Review before hand-back

Delegate one reviewer, told to change no files, with its subagent model set to whichever of `claude-agent/opus` and `openai/gpt-6.2-sol` you are not running on. It reads the log and follows each row's evidence, such as the commit, diff, or artifact, and flags what the user should look at, without redoing the work:

- rows whose evidence is missing or does not show what the row claims
- verification skipped, or claimed without proof in the evidence
- choices that look risky in hindsight, such as premature, scope-creeping, or papering over a symptom
- gaps the user would miss on a quick skim

When a flag shows a row is wrong, add a row that supersedes it.

## Output

Every reply for a run that kept a log ends with an **Attention** section. Its first line is `reviewed by <model>`. Then list each flag with the row it points at. "No flags" is a valid list. The model name is required.
