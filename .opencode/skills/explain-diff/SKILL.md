---
name: explain-diff
description: Explains the differences of a code change, diff, branch, or pull request. Use when the user asks for a explanation of a code change, diff, branch, or pull request.
---

Make me a rich explanation of the code change.

It should have these sections:

- Background: Explain the existing system relevant to this change. (You should broadly explore surrounding code for this). Assume that user is already familiar of project so do not include a deep background, but more narrow background directly relevant to the change.
- Intuition: Explain the core intuition for the code change. The focus here is to explain the essence, not the full details. Use concrete examples with toy data. Use figures and diagrams liberally.
- Code: Do a high-level walkthrough of the changes to the code. Group/order the changes in an understandable way.

Format:

- Generated file always lives under `$TMPDIR/explain-diff/<topic>` and is named `index.md` like `$TMPDIR/explain-diff/implement-plan-selector/index.md`. Attached files are copied into the same directory, `$TMPDIR/explain-diff/implement-plan-selector/*` and linked in the Markdown document with relative paths.
- Output a single self-contained Markdown document. Make the whole thing one long page with section headers and a table of contents.
- Don't use tabs for the top-level structure.
- Use callouts for key concepts or definitions, important edge cases, etc.
- Use ASCII diagrams for system architecture or data flow, if helpful.
- Do not use any external diagrams like Mermaid, PlantUML, etc.

After writing the explanation:

Come up with five questions that test the reader's knowledge of this PR. This should be medium difficulty, difficult enough that you actually need to understand the substance of the PR to answer them, but not gotchas. The goal is to help the reader make sure that they've actually understood. These should be presented with `question` tool, and when the user answers, it tells them whether they were correct and gives feedback.
