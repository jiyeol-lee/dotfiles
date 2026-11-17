---
description: Mine this session for durable lessons and route each to a concrete edit on an existing skill or AGENTS.md.
---

Find lessons in this session that should change how agents work next time, and propose edits for them. Stop early and say so when the session was trivial or every skill was followed correctly. A one-off is not a lesson.

1. **Export the transcript.** Run these two commands as written. The shell fills in `$OPENCODE_SESSION_ID` with this session's ID:
   - `mkdir -p "/tmp/agentic-coding-tool/reflect-$OPENCODE_SESSION_ID"`
   - `opencode session export "$OPENCODE_SESSION_ID" > "/tmp/agentic-coding-tool/reflect-$OPENCODE_SESSION_ID/session.json"`
2. **Review in parallel.** Delegate four reviews in one message, each told to change no files, each with the transcript path and one lens:
   - Corrections: where the user corrected the agent, rejected work, or repeated an instruction.
   - Tooling: commands that failed, permissions that blocked, and tools used the wrong way or the slow way.
   - Missed triggers: a skill that should have loaded and did not, one that loaded when it should not have, or a skill step that was skipped or missing.
   - Divergent: approaches nobody raised that would have worked better, such as a skill, skill step, check, or tool that would have saved time or caught a mistake earlier.
     Each finding quotes the transcript as evidence and names the lesson, the target file, and the proposed edit.
3. **Synthesize.** Merge and dedupe the findings. Check each against the current skills, and drop any that a skill already covers and the agent simply did not follow. Sort the rest into Accepted, Rejected, and Backlog.
4. **Prefer structure.** If a lint rule, type, test, permission rule, or script would enforce a lesson more reliably than prose, move it to Backlog and name that enforcement.
5. **Route each accepted lesson** to the kind and file that the `authoring-skills` skill picks. A skill that missed or misfired its trigger gets its `description` tightened. A reply-style lesson goes to the `output-styles` skill.
6. **Present and wait.** Show every Accepted edit as before and after, with its target file. Apply only the edits the user approves.
7. **Apply every approved edit with the `authoring-skills` skill**, whatever its size.

## Output

Every report includes these sections:

- **Accepted**: each edit with its target file, the before and after text, and the transcript evidence.
- **Rejected**: each dropped finding with its reason.
- **Backlog**: each lesson better enforced by structure, with the enforcement named.
