# Prototype playbook

You own the design decision, not the code. The prototype is a throwaway instrument, and the real build follows the Feature playbook. Speed beats polish here: no planning, no tests, no abstractions. The rigor is in picking the right design cheaply, so propose variations the user did not ask for.

## Steps

1. **Scope the decision** the prototype exists to make, such as which layout, which interaction, which approach, or which behavior or timing.
2. **Gather references** when the design space is open: prior art, existing patterns in the codebase, and options for the user to pick a direction. Skip when the direction is set.
3. **Build throwaway** in `/tmp/agentic-coding-tool/prototype-<slug>/`, apart from production source. For a visual decision, plain HTML, CSS, and JS or the lightest stack that renders the idea. For a behavior or timing decision, the smallest script that exercises the question.
4. **Compare variants side by side.** For a visual decision, put them behind one switcher, such as buttons or a keypress, each labeled. For a behavior decision, run each variant with the same input.
5. **Observe the thing you are deciding.** For a visual decision, screenshot each variant and drive the interaction with the `browse` MCP tools. For a behavior or timing decision, log the timing or print the output. The observation is the test.
6. **Recommend.** Present the variants, the evidence, the tradeoffs, and your pick. Hand the chosen direction to the Feature playbook, or to the `architect` skill for the shape.

## Reply

Every reply includes these sections:

- **Variants**: each one you explored.
- **Evidence**: screenshots, observed output, or timing for each.
- **Tradeoffs**: what each variant costs and buys.
- **Recommendation**: your pick, and the playbook or skill that builds it for real.
- **Scratch path**: where the prototype lives, stated plainly as throwaway.
