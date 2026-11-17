---
name: authoring-skills
description: Writes or edits a skill, principle, or language guideline so the model loads it at the right moment and it conflicts with no other. Use when creating, changing, renaming, or removing a skill, principle, or language guideline.
---

# Authoring skills

You own the skill's voice and its place among the others. Keep only prose that changes a decision. Tell the agent what to do, and explain why only when the rule is confusing without a reason.

## Steps

1. **Pick the kind.** The model loads every kind on its own, so each `description` is its trigger.
   - Tool skill: one step done well, such as `arena` or `tdd`. It triggers on the step or moment it serves.
   - Workflow skill: a multi-step job with its own authority or exit condition, such as `autopilot` or `hillclimb`. It triggers on the request that grants that authority or names that exit condition. State exactly what the request authorizes.
   - Principle: one rule for one kind of decision, named `principle-<name>`. It triggers on the moment that decision comes up. It never grants or takes away authority.
   - Language guideline: conventions for one language or tool, in `skills/language-guidelines/references/<language>.md`. Add to the existing reference for that language, or create one and list it in the `language-guidelines` skill. Give each rule a "Do it like this" and a "Not like this" code example, and keep it generic, not tied to one project.
2. **Check for overlap.** Read the description of every skill of the same kind. Name the one decision, step, or request the new skill owns, and show that no existing skill owns it or triggers at the same moment. If one does, change that skill instead of adding another.
3. **Write the body.** Steps a reader can follow in order. Point at other skills by name instead of restating them. When a rule could be enforced by a permission, lint, type, test, or script instead of prose, enforce it there. A tool or workflow skill ends with a section that names the sections every answer must include.
4. **Write the description** in this order: what the skill does, what it is not for, then when to use it. "\<What it does\>. Not for \<near miss\>. Use when \<the moment or request\>, such as \<phrases\>." Leave out the "Not for" sentence when no skill is a near miss. Never point to another skill or place in the description.
5. **Wire it in.** Add a skill allow in `opencode.jsonc` unless a pattern such as `principle-*` already covers it. Update every reference to an old or renamed name; grep `.opencode/` for it.
6. **Validate.** The frontmatter `name` matches the directory, every referenced file exists, `opencode reload` succeeds, and `opencode debug agents` shows the skill allowed.
7. **Test it in `~/dev/agent-harness-evals`.** Add or update a scenario whose `checks.md` says when the skill should load and which near miss must not, then run the scenarios the change touches with `go run ./run -s <ids> -n 3`. Skip it for wording-only changes.
8. **Ship it** the way the repository ships changes: the `pull-request` skill, or a direct commit where the repository commits to its default branch.

When a workflow keeps coming up and no skill captures it, propose a new skill.

## Reply

Every reply includes these sections:

- **Skill**: what it does, and its kind.
- **Overlap**: the near misses checked in step 2, and why each one does not own this.
- **Design decisions**: the choices that shaped it, with reasons.
- **Validation**: the checks from step 6, and the eval result when step 7 ran.
