# Authoring a skill playbook

You own the skill's voice. Keep only prose that changes a decision. Tell the agent what to do, and explain why only when the rule is confusing without a reason.

## Steps

1. **Pick the kind.**
   - Tool skill: one step done well, such as `arena` or `tdd`. The model loads it on its own, so its `description` is its trigger.
   - Principle: one rule for one kind of decision, named `principle-<name>`. The model loads it on its own, so its `description` is its trigger.
   - Language guideline: conventions for one language or tool, in `skills/language-guidelines/references/<language>.md`. Add to the existing reference for that language, or create one and list it in the `language-guidelines` skill. Give each rule a "Do it like this" and a "Not like this" code example, and keep it generic, not tied to one project.
   - Playbook: a whole task. Write it as `skills/drill/playbooks/<name>.md` with no frontmatter, and list it in the drill skill's Playbooks section.
2. **Write the body.** Steps a reader can follow in order. Point at other skills by name instead of restating them. Point at a playbook as "the <name> playbook from the `drill` skill", never by its file path; the drill skill's index maps the name to the file. When a rule could be enforced by a permission, lint, type, test, or script instead of prose, enforce it there. A tool skill ends with an Output section that names the sections every answer must include.
3. **Write the description** in this order: what the skill does, what it is not for, then when to use it. "\<What it does\>. Not for \<near miss\>. Use when \<the step or moment\>, such as \<phrases\>." Leave out the "Not for" sentence when there is no near miss. Never point to another skill or place in the description. Trigger on the step or moment, not on a task type, so it does not compete with playbooks.
4. **Wire it in.** Add a skill allow in `opencode.jsonc` unless a pattern such as `principle-*` already covers it. Update every reference to an old or renamed name; grep `.opencode/` for it.
5. **Validate.** The frontmatter `name` matches the directory, every referenced file exists, `opencode reload` succeeds, and `opencode debug agents` shows the skill allowed.
6. **Test it in `~/dev/agent-harness-evals`.** Add or update a scenario whose `checks.md` says when the skill should load and when it must not, then run the scenarios the change touches with `go run ./run -s <ids> -n 3`. Skip it for wording-only changes.
7. **Ship it** the way the repository ships changes: the `pull-request` skill, or a direct commit where the repository commits to its default branch.

When a workflow keeps coming up and no skill captures it, propose a new skill.

## Reply

Every reply includes these sections:

- **Skill**: what it does, and its kind.
- **Design decisions**: the choices that shaped it, with reasons.
- **Validation**: the checks from step 5, and the eval result when step 6 ran.
