---
name: gardening
description: Finds patterns in an area of code that agents would copy, ranks them, and removes only the groups the user picks, each with a rule that stops it from coming back. Not for one known bug or one requested refactor. Use when the user asks for a cleanup pass or a hunt for code smells, slop, lint suppressions, or recurring review findings across an area.
---

# Gardening

You watch what grows into the codebase and pull weeds before agents copy them. Existing bad code teaches agents to write more of it. Every weed you pull becomes a rule so it cannot grow back. Prefer rules in code, such as types, lint rules, CI checks, and tests, over guidance in prose.

Steps 1 to 4 are read-only. Fix only the groups the user picks in step 4.

## Steps

1. **Pick the area.** Use the PRs, directories, or modules the user names. If they name none, scan the PRs merged in the last 14 days and say so.
2. **Hunt for weeds** with a coverage pass of the `swarm` skill, one read-only worker per slice of the area. Look for:
   - the same workaround or helper written more than once
   - lint, type, or test suppressions, such as `eslint-disable`, `@ts-expect-error`, `# type: ignore`, `//nolint`, or skipped tests
   - dead code, unused exports, and shims with no remaining callers
   - docs, comments, or examples that mislead, since agents copy them
   - tests that assert implementation instead of behavior, or repeat other tests
   - two or more ways to do the same thing where one paved road should exist
3. **Log the findings before fixing anything.** Write each weed with its location and evidence in a table. Group weeds that share a root cause. Three similar weeds are one problem. Label a suspected bug as suspected until a run shows it.
4. **Rank and propose.** Number the groups and rank them by how fast they spread and how much they cost to fix. For each group, propose the fix and the rule that would stop it from coming back. Present the ranked list and wait for the user to pick.
5. **Pull each picked group** as its own change, keeping the numbering from step 4:
   1. Add the rule first, and confirm it fails on the current weeds.
   2. Remove the weeds. Pin behavior before moving structure; a weed that is a real defect gets its root cause fixed.
   3. Confirm the rule passes.
   4. If no rule can catch the weed, write the guidance next to the code it governs, and use AGENTS.md only as a last resort.
6. **Hand back** each change. Open a pull request with the `pull-request` skill only when the user asked for one.

## Reply

Every reply includes these sections:

- **Area**: what you scanned.
- **Findings**: the weeds, grouped by root cause.
- **Pulled**: each group you removed, and the rule that now prevents it.
- **Left**: what you left, and why.
