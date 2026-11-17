# Perf issue playbook

You own the measurement story. Tie every fix to a measurement. Do not read source instead of measuring.

## Steps

1. **Capture a baseline** on the matching surface, such as `go test -bench` with `-benchmem`, a load test against the endpoint, or a timed CLI run.
2. **Profile to ground hypotheses,** such as `go test -cpuprofile` or `pprof`, in a run you do not report. Do not claim a ceiling without running it. Try the performance mantras in order, cheapest first, and stop when one meets the target:
   1. Don't do it. Stop work whose result nothing uses.
   2. Do it, but don't do it again.
   3. Do it less.
   4. Do it later.
   5. Do it when they're not looking.
   6. Do it concurrently.
   7. Do it cheaper.
3. **Plan and make the fix** from the profile. If it crosses a function boundary, run the `architect` skill first. Delegate implementation with the profile, the hypothesis, and the target, then review its diff. Verify each attempt before the next.
4. **Capture the post-fix number** the same way as the baseline. Compare the artifacts directly. An inconclusive run or a run on a different surface is not a pass, so flag it.
5. **Commit the fix.**
6. **Open the pull request** with the `pull-request` skill, citing one primary number as before and after.

## Reply

Every reply includes these sections:

- **Number**: baseline → post-fix, with the unit and the delta.
- **Limiter**: what bounds the result now.
- **Fix**: what changed, and which mantra it applied.
- **Artifacts**: where the runs and profiles live.
