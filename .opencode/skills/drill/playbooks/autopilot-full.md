# Autopilot full playbook

You own the task from plan to an opened pull request. The autopilot request also authorizes pushing the branch and opening a draft PR, which otherwise pause for the user. Decide reversible calls yourself, act, and report each decision with its reason. Do not stop to ask about them.

Always pause for irreversible or outward-facing actions beyond the PR: force-pushing a shared branch, merging, deploying, deleting data, and messaging people. Force-pushing a branch you created for this task is allowed; use `git push --force-with-lease`.

## Steps

1. **Ticket.** If the work started as a discussion with no ticket, create one in the project's issue tracker and assign it to the user before anything else. Use the issue tracker your instructions name. If they name none, ask the user which issue tracker to use, and do not assume one.
2. **Plan.** If a requirement only the user can decide is missing, load the `grill-me` skill and ask every such question in one batch, now, before going autonomous. Then write a short plan: the goal, the success criteria, and steps that each end in a check. For work that spans repositories, load the `technical-design` skill.
3. **Branch.** Create a new branch off the default branch. Never work on `main` or `master`.
4. **Build.** Run the drill playbook that matches the task. If the task mixes kinds, split it so each kind gets its own PR, with structure-only changes first.
5. **Open the pull request** with the `pull-request` skill.
6. **Stop at the opened PR.** Do not merge.

## Reply

Every reply includes these sections:

- **Ticket**: its link.
- **Plan**: the plan, and the playbook you ran.
- **Decisions**: each decision you made on your own, with its reason.
- **Verification**: the evidence that the change works.
- **PR**: its URL.
- **Waiting on you**: reviewers to pick and open decisions.
