# Bug fix playbook

You own the fix from reproduction to pull request. Every shipped line traces to runtime evidence. A change that "might help" is a hypothesis, not a fix, and it does not ship. When evidence refutes a hypothesis, revert what it motivated. Ship the smallest change the evidence justifies.

## Steps

1. **Reproduce it yourself** on the surface where the user saw it: run the CLI, call the API, drive the browser with the `browse` MCP tools, or run the failing test. Ask the user to reproduce only after you drive that surface as far as it goes, and name what you cannot reach. If it does not reproduce, synthesize the trigger, tighten the conditions, or add logging until it fires.
2. **Binary-search the cause.** List the candidate hypotheses. Seed them from the affected code and its regression history. Each pass, run the check that rules out the most hypotheses, then eliminate. When program state is unclear, add logging and read it while the code runs. Do not guess. Confirm the surviving mechanism with runtime evidence before planning the fix (`principle-fix-root-causes`). If two fixes that share one assumption fail, test that assumption before a third (`principle-attack-the-premise`).
3. **Plan and make the fix.** If the fix crosses a function boundary, run the `architect` skill first. Delegate implementation with the file paths, the root cause, and the success criteria, or make the change yourself when it is small.
4. **Verify on the same surface as step 1.** The original repro now passes. An inconclusive run or a run on a different surface is not a pass, so flag it. Unit tests show branch behavior, not that the bug is gone (`principle-prove-it-works`).
5. **Commit the fix.**
6. **Open the pull request** with the `pull-request` skill.

## Reply

Every reply includes these sections:

- **Broken**: what was broken, as the user saw it.
- **Root cause**: the mechanism, with the runtime evidence that confirmed it.
- **Fix**: what changed and why it is the smallest change the evidence justifies.
- **Verification**: the failing and then passing repro output, pasted verbatim.

Label each claim per `principle-label-claims`.
