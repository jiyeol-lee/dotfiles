# <repository>

Back to [README.md](README.md).

## Design

### Behavior

The behavior and rules first, then the data shapes, the contracts it owns, and links to the contracts it calls. A choice that affects only this repository states its reason here.

### Data migration

Describe this repository's migration of existing data, even for a small or single-repository migration. Include the applicable details:

- Source-to-target transformations and treatment of existing records.
- Backfill behavior, concurrent-write handling, and compatibility while old and new versions coexist.
- Progress tracking, restart and retry behavior, and failure recovery.
- Completeness and consistency checks that allow cutover.
- Rollback, irreversible boundaries, and cleanup conditions.

Omit this section when this repository owns no data migration.

### Program layout

Show changed files and the existing context needed to understand them. Use indentation only, without tree connectors. Mark changes relative to the repository's main branch: `[+]` added, `[~]` updated, `[-]` deleted, and unmarked existing context. Put a one-line purpose or change explanation after `#` on the same line as each filename.

```text
src/
  feature/
    [+] handler.ext       # Handle the new request path
    [~] storage.ext       # Save the new state
    [-] legacy.ext        # Replaced by handler.ext
    contract.ext          # Existing request contract
tests/
  [+] <new-file>          # Cover the new behavior
  [~] <existing-file>     # Cover changed expectations
```

### Runtime flow

Use a plain-language ASCII diagram for each materially different runtime path. Name files only when that helps connect the flow to Program layout. Show important decisions, failure branches, and transaction boundaries where relevant. Do not list functions or walk through source code.

## Tests

Group planned tests by file, not in a table or framework syntax. Each file heading includes a repository-relative path and a `[+]`, `[~]`, or `[-]` marker, using the same main-branch baseline as Program layout. Give each file one short approach note, explaining real or replaced dependencies when meaningful.

Use natural-language bullets for scenarios, each with a change marker, a concise behavior label, the setup, and the observable expected result. File and scenario markers are independent. Include only markers that apply. Updated cases state the target expectation. Removed cases explain the obsolete expectation or where coverage moves. Add short `input -> action -> result` text pseudocode only where useful.

### [+] tests/<new-file>

Approach: <How the file checks behavior, including real or replaced dependencies when meaningful.>

- [+] <Behavior label>. Given <setup>, <action> produces <observable result>.

Optional pseudocode for a case:

```text
<input> -> <action> -> <observable result>
```

### [~] tests/<existing-file>

Approach: <One short note on how the file checks behavior.>

- [+] <Added behavior>. Given <setup>, <action> produces <observable result>.
- [~] <Updated behavior>. Given <setup>, <action> produces <target observable result>.
- [-] <Removed expectation>. <Why it is obsolete or where coverage moves.>

## Failures

| Failure | What happens | Recovery | Detected by |
| ------- | ------------ | -------- | ----------- |

Detected by names the alarm or signal that catches the failure. When nothing catches it, write Nothing and add the failure to the README's Open questions. Omit this section when the repository has no failure case in this design.

## Infrastructure

Omit this section unless this repository owns infrastructure for the design. It holds the Resources, Outputs, and Alarms tables from the infrastructure repository file template.

## Tickets

| Ticket | Scope |
| ------ | ----- |
