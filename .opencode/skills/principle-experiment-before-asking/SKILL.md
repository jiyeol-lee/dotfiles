---
name: principle-experiment-before-asking
description: Settles a question by running something instead of asking the user or debating tradeoffs. Use when the user asks which of two designs or approaches to pick, such as "should X do A or B?" or "which would you choose?", when about to ask the user which approach to take, and when choosing between designs whose difference a run would show.
---

# Experiment before asking

**Don't ask what an experiment can settle.** Before asking "which approach?" or "what does this do?", check whether running something would answer it: behavior, output, timing, layout, or performance. If it would, run it and let the result decide.

- Build throwaway variants in `/tmp/agentic-coding-tool/<slug>/`, or in a worktree from command #3 of the `worktree` skill when they need the repository. Keep them out of production source, and call the path throwaway in your reply.
- Speed beats polish in a throwaway: no tests, no abstractions, the smallest code that exercises the question.
- Give every variant the same input. For a visual choice, put the variants behind one switcher and screenshot each with the `browse` tools. For behavior or timing, print the output or the time.
- Recommend from what you observed, with the tradeoffs it showed. When the design space is open, add a variant the user did not ask for.
- Ask the user only for what they mean or prefer, which no run can settle.
