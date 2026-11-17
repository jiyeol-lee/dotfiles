# Feature playbook

You own the design. Name the data shape before writing logic, build in small verified units, and prove the result on the real surface.

## Steps

1. **Learn the affected code.** Read the code the feature touches. Reuse an existing pattern before adding a new one.
2. **Name the data shape**, per the drill skill's Always section.
3. **Design.** If a design document already settles the design, follow it as written, and report any decision that cannot be built as written. Otherwise, if the change crosses a function boundary, run the `architect` skill. If it spans repositories or reviewers must agree before building, load the `technical-design` skill and write the design document. Keep the design to what was asked (`principle-simplicity-first`). Fit the requirement into the design as if it had been there from the start, not bolted on (`principle-redesign-from-first-principles`).
4. **Split the work into small units** that each end in a check: a test, a build, or a run. Write the throughput checkpoint from the drill skill's Always section, then fan out per it.
5. **Build each unit**, one at a time:
   1. **Build it.** If the unit makes existing code obsolete, remove it before building its replacement (`principle-subtract-before-you-add`). Delegate code-writing with a specific scope: file paths, the data shape, and the success criteria. When the implementation admits several valid shapes, such as error handling, abstraction layer, or test structure, run the `arena` skill instead. When the unit improves a shared helper or component, port the improvement to every consumer.
   2. **Verify it** with the unit's check, and verify each consumer it changed.
   3. **Commit it** before starting the next unit.
6. **Verify on the matching surface**: run the CLI, call the endpoint, or drive the UI with the `browse` MCP tools. An inconclusive run or a run on a different surface is not a pass, so flag it (`principle-prove-it-works`).
7. **Review a contested design** with the `interrogate` skill, per the drill skill's Always section, then fix the verified findings.
8. **Open the pull request** with the `pull-request` skill.

## Reply

Every reply includes these sections:

- **Built**: what you built.
- **Choices**: what you chose and why, with design alternatives in a table.
- **Throughput checkpoint**: the four items from step 4.
- **Verification**: how you verified it on the real surface.
- **Open decisions**: what still needs the user.

Label each claim per `principle-label-claims`.
