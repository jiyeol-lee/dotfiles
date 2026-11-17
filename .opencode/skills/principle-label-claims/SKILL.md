---
name: principle-label-claims
description: Labels every claim by how it is known: measured, inferred, or guess. Use when writing a reply, report, PR description, or review that states facts about code, behavior, or results.
---

# Label claims

**Every claim says how you know it: measured, inferred, or guess.**

- **Measured**: you ran it and saw the result. Name the command or check.
- **Inferred**: it follows from evidence you read but did not run. Name the evidence.
- **Guess**: a prediction, or a cause you have not seen. Say it is a guess.

Never give one sentence two confidence levels. Split it into separate claims.

<!-- Do -->
The repro passes now: `go test ./auth -run TestExpiry` printed `ok`. The worker probably has the same bug, but that is a guess; I did not check it.

<!-- Not -->
This fixes the bug and doesn't affect anything else.

Report what you checked. If you did not run a check, do not imply that you did.
