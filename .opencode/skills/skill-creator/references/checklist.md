# Skill Quality Checklist

Validate every item before presenting a skill to the user.

## Frontmatter

- [ ] `name` is kebab-case (lowercase letters, numbers, hyphens only)
- [ ] `name` is max 64 characters
- [ ] `name` does not start or end with a hyphen
- [ ] `name` does not contain consecutive hyphens (`--`)
- [ ] `name` does not contain reserved words ("anthropic", "claude")
- [ ] `name` does not contain XML tags
- [ ] `description` is non-empty and max 1024 characters
- [ ] `description` does not contain XML tags
- [ ] `description` states what the skill does (first part)
- [ ] `description` states when to use it with trigger phrases (second part)
- [ ] `description` uses imperative phrasing ("Use when...")
- [ ] `description` includes specific trigger phrases matching user language

## Body Content

- [ ] Body is under 500 lines
- [ ] Body is under ~5,000 tokens
- [ ] Every instruction passes the litmus test: "Would the agent get this wrong without this?"
- [ ] No generic knowledge the LLM already has (unless project-specific variation exists)
- [ ] At least one concrete working example (input → output)
- [ ] Procedures (how to approach) over declarations (what to produce)
- [ ] Prescriptive language where exactness matters (MUST, ALWAYS, NEVER)
- [ ] Flexible language where variation is fine (consider, when appropriate)
- [ ] No time-sensitive information (or clearly marked as such)

## Progressive Disclosure

- [ ] SKILL.md contains only core instructions needed on every run
- [ ] Detailed reference material is in separate files (if applicable)
- [ ] Reference files use conditional loading: "Read X **when** [condition]"
- [ ] No generic references ("see docs for details")
- [ ] Reference files are organized by domain/feature, not generic names

## Scope & Coherence

- [ ] Skill covers one coherent unit of work (not too narrow, not too broad)
- [ ] Skill composes well with other skills (no overlapping responsibilities)
- [ ] Skill has clear boundaries (what it does AND what it doesn't do)

## Structure

- [ ] Directory uses kebab-case naming matching the `name` field
- [ ] SKILL.md file is named exactly `SKILL.md` (case-sensitive)
- [ ] Optional directories follow convention: `scripts/`, `references/`, `assets/`
- [ ] Scripts are self-contained or document dependencies
- [ ] Scripts include helpful error messages

## Quality Signals

- [ ] Grounded in real expertise (not generic LLM knowledge)
- [ ] Includes gotchas or edge cases specific to the domain
- [ ] Error handling guidance is included where relevant
- [ ] Constraints section lists things that are NEVER allowed
