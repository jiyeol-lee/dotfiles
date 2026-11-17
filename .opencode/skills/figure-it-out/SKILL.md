---
name: figure-it-out
description: Designs and runs an auditable workflow that scales rigor to the task, runs each unit as an experiment, and keeps a decision log. Use for large or cross-cutting work, work the user reviews after stepping away, or a task no drill playbook fits.
metadata:
  opencode/autoinvoke: false
---

# Figure it out

The deliverable before any code is the workflow itself: a sequence of phases that scales rigor to the task, follows the scientific method, and leaves a decision trail a human can audit after stepping away.

## Start

Copy the phases below into the todo list, in order.

## Phase A: Frame

Ground first, then commit. Do not start the run until you can state:

- **Done**, as a check that can pass or fail (`principle-prove-it-works` skill).
- **Scope**, quantified: rough units and effort, and the blockers that grounding surfaced.
- **Rigor**, biased high. One-way decisions and a wide blast radius get more; reversible, low-stakes steps get less. Rigor means gates and artifacts, not trying harder.

Present the framing and tradeoffs, then keep going. Reversible work does not wait for an answer. A run expected to take several hours earns one checkpoint with the user before it starts.

## Phase B: Design the workflow

Split the work into units that each land on their own. Put the riskiest unknown first, and put scaffolding and verification before features.

- **Build the verification harness before the work**, and capture the value before any change, so each check reads as the old value against the new value.
- **Run the `architect` skill only for one-way design decisions.** Skip it for mechanical work whose shape is already clear. A second arena over a settled design is more than the job needs.
- **Fan out only where the work splits cleanly.** Give each worker its own worktree from command #1 of the `worktree` skill. Do not fan out more than the seams allow.
- **Write the phase list down.** That list is what the user reviews.

Add the designed units to the todo list between Phase C and Phase D, and log a row as each one lands instead of saving the log for the end.

## Phase C: Run each unit as an experiment

For each unit:

1. **Change.** State the hypothesis and make the smallest change.
2. **Measure** against the Phase A check on the real artifact. A result is VERIFIED, NOT VERIFIED, or INCONCLUSIVE, and inconclusive is not a pass. Do not hide a negative result. Verify by inspecting the artifact, never by reading a delegate's report (`principle-prove-it-works`). Pair delegated units with a judge whose subagent model is set to whichever of `claude-agent/opus` and `openai/gpt-6.2-sol` you are not running on now. When something passes too easily, suspect the measurement before the result.
3. **Keep or revert.** Keep the change only if it advanced; otherwise revert it in full. If a worker games the check, reset its work and tighten its brief. If the check itself is wrong, fix the check in its own change instead of routing around it.
4. **Commit the kept unit** before starting the next.
5. **Log the row** per the `show-me-your-work` skill, whether the unit was kept or reverted.

## Phase D: Keep the decision log

Keep it with the `show-me-your-work` skill, which owns its location and format. This work is usually ambitious enough that a reviewer needs the log, so copy it into the pull request's branch when the user will review the run later.

## Phase E: Verify and hand back

1. **Verify the whole** against the Phase A check on the real product, not only the harness.
2. **Get the log reviewed** per the `show-me-your-work` skill.
3. **Open the pull requests** with the `pull-request` skill, one per unit or group that lands on its own.

## Output

Every reply includes these sections:

- **Workflow**: the phases you designed.
- **Rigor**: the level you picked and why.
- **Verified**: each result against the Phase A check, as VERIFIED, NOT VERIFIED, or INCONCLUSIVE.
- **Decision log**: its path.
- **Open**: what is still open.
- **Attention**: per the `show-me-your-work` skill.

Label each claim per `principle-label-claims`.
