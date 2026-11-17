---
name: arena
description: Spawn N parallel candidates on the same task, pick a base, and graft the strongest parts of the losers into it. Use for /arena, 'arena this', 'throw it in the arena', or when one attempt at a non-trivial artifact would lock in the wrong shape.
---

# Arena

Several delegates build the same artifact in parallel, a judge scores them, and you build the result from the best one plus the strongest parts of the others.

## Steps

1. **Frame.** Write one task prompt that every candidate gets: the artifact, the grounding files, the constraints, and the success criteria. Write a rubric of three to six gradeable criteria for this task. Only you and the judge see the rubric.
2. **Give each candidate a different direction.** Assign each a distinct approach or priority, such as "smallest diff", "strongest types", or "no new module", so candidates on the same model do not converge on the same answer. Use two to four candidates.
3. **Fan out.** Delegate one candidate each, all in one message. Set each one's subagent model, alternating `claude-agent/opus` and `openai/gpt-6.2-sol`. Each returns its artifact and a short rationale in its reply: what it considered and rejected. Only when a candidate must compile or run its code to prove it, have it write to `/tmp/agentic-coding-tool/arena-<slug>/candidate-<n>/` and nowhere else. If a candidate returns nothing, continue with the rest and note it.
4. **Judge.** After every candidate finishes, delegate one judge. Set its subagent model set to whichever of `claude-agent/opus` and `openai/gpt-6.2-sol` you are not running on now. Tell it to change no files, and give it the rubric and the candidates labeled by number only. It scores each candidate per criterion and recommends a base with its reason.
5. **Pick a base.** Read every candidate in full and score each against the rubric yourself. If you and the judge disagree, reread both rationales before deciding, because the disagreement means a bias or an unclear rubric. When two tie, pick the smaller interface or the cleaner boundary.
6. **Graft.** Walk each losing candidate once more for what is worth porting into the base, usually one or two things per candidate, not most of it. Fold each graft in by hand, per the `principle-redesign-from-first-principles` principle skill, so the result stays coherent under one mental model. Don't paste mechanically. If the candidates converged, note the agreement and skip grafting. If they diverged wildly, the frame was unclear, so rewrite it and rerun instead of averaging.
7. **Verify** the result like any other output.

## Output

Every arena report includes these sections:

- **Base**: the chosen candidate and why.
- **Judge**: the judge's scores and recommendation, and whether you agreed.
- **Grafts**: each idea ported in, with its source candidate.
- **Rejected**: what you left out and why.
- **Verification**: how you verified the result.
