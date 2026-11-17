# Gardening playbook

You watch what grows into the codebase and pull weeds before agents copy them. Existing bad code teaches agents to write more of it. Every weed you pull becomes a rule so it cannot grow back. Prefer rules in code, such as types, lint rules, CI checks, and tests, over guidance in prose.

Steps 1 to 4 are read-only. Fix only the groups the user picks in step 4.

## Steps

1. **Pick the area.** Use the PRs, directories, or modules the user names. If they name none, scan the PRs merged in the last 14 days and say so.
2. **Hunt for weeds.** Split the area across parallel delegates that read and change nothing. Look for:
   - the same workaround or helper written more than once
   - lint, type, or test suppressions, such as `eslint-disable`, `@ts-expect-error`, `# type: ignore`, `//nolint`, or skipped tests
   - dead code, unused exports, and shims with no remaining callers
   - docs, comments, or examples that mislead, since agents copy them
   - tests that assert implementation instead of behavior, or repeat other tests
   - two or more ways to do the same thing where one paved road should exist
3. **Log the findings before fixing anything.** Write each weed with its location and evidence in a table. Group weeds that share a root cause. Three similar weeds are one problem.
4. **Rank and propose.** Rank the groups by how fast they spread and how much they cost to fix. For each group, propose the fix and the rule that would stop it from coming back. Present the ranked list and wait for the user to pick.
5. **Pull each picked group in its own pull request.**
   1. Add the rule first, and confirm it fails on the current weeds.
   2. Remove the weeds with the Refactoring playbook, or the Bug fix playbook when a weed is a real defect.
   3. Confirm the rule passes.
   4. If no rule can catch the weed, write the guidance next to the code it governs, and use AGENTS.md only as a last resort.
6. **Open each pull request** with the `pull-request` skill.

## Reply

Every reply includes these sections:

- **Area**: what you scanned.
- **Findings**: the weeds, grouped by root cause.
- **Pulled**: each group you removed, and the rule that now prevents it.
- **Left**: what you left, and why.
