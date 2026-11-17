---
name: grill-me
description: Interviews the user in rounds of questions until there is no gap between what they mean and what the agent understands. Not for trying to break code or a diff. Use when the user asks to be grilled or to stress-test a plan, design, decision, or idea through questions ("grill me", "poke holes in this plan", "interview me about this", "help me think this through"), and when another skill's step names it.
---

# Grill me

Interview the user relentlessly until you reach a shared understanding, with no gap between what they mean and what you understand. Map the plan as a **design tree**: every decision branches into the decisions that hang off it. Change nothing while grilling.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask now without guessing at answers you have not heard yet. Ask the whole frontier in one round, number each question, and give your recommended answer, worded so "yes" accepts it:

```
**Q1. <question title>**
<question body, with the options when there are several>

Recommended: <your answer, and why>

**Q2. <question title>**
...
```

Each round of answers reshapes the tree: settled decisions unblock the questions that depended on them. Recompute the frontier and ask the next round. A question that depends on another question still open in this round belongs to a later round.

Finding facts is your job, never the user's. When a question needs a fact from the code, config, or tools, look it up or delegate the lookup, and do not ask the user. Do not block on a running lookup: only the questions downstream of it wait. The decisions are the user's: put each to them and wait.

The grilling is done when the frontier is empty: every branch visited, nothing left silently assumed. Do not act on the plan until the user confirms you have reached a shared understanding.
