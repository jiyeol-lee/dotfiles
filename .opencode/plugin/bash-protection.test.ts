import assert from "node:assert/strict";
import test from "node:test";
import { BashProtection } from "./bash-protection.ts";

const protection = await BashProtection(
  {} as Parameters<typeof BashProtection>[0],
);
const before = protection["tool.execute.before"];

if (!before) {
  throw new Error("BashProtection did not register its before hook");
}

const runBash = (command: string) =>
  before(
    { tool: "bash", sessionID: "test-session", callID: "test-call" },
    { args: { command } },
  );

test("rejects backslash line continuations and trailing backslashes", async () => {
  const message =
    "Backslash line continuations and trailing backslashes are not allowed in bash commands.";
  const trailingWhitespace = ["", " ", "\t", " \t", "\t "];

  for (const lineEnding of ["\n", "\r\n"]) {
    for (const whitespace of trailingWhitespace) {
      await assert.rejects(
        runBash(`command1\\${whitespace}${lineEnding}command2`),
        { message },
      );
    }
  }

  for (const whitespace of trailingWhitespace) {
    await assert.rejects(runBash(`command1\\${whitespace}`), { message });
  }
});

test("allows backslashes that are not at a line or input boundary", async () => {
  for (const command of [
    "printf 'one\\two'",
    "printf '/tmp/one\\two'",
  ]) {
    await assert.doesNotReject(runBash(command));
  }
});

test("rejects raw shell separator and control characters", async () => {
  for (const command of [
    "printf 'one;two'",
    "printf 'one&two'",
    "printf 'one|two'",
    "printf 'one&&two'",
    "printf 'one||two'",
    "printf 'one\rtwo'",
    "printf 'one\ntwo'",
    "printf one\necho two",
    "git status\n",
  ]) {
    await assert.rejects(
      runBash(command),
      /Shell separator and control characters/,
    );
  }
});

test("rejects direct denied Git commands", async () => {
  for (const command of [
    "git -C /tmp status",
    "git worktree list",
    "git checkout main",
    "git stash",
    "git pop",
    "git -c color.ui=false checkout main",
    "git -c alias.co=checkout co mai",
    "git -c color.ui=false status",
  ]) {
    await assert.rejects(runBash(command), {
      message:
        "`git -c`, `git -C`, `git worktree`, `git checkout`, `git stash`, `git pop` commands are not allowed.",
    });
  }
});

test("rejects every denied Git target after supported options", async () => {
  const supportedOptions = ["--no-pager", "--git-dir=.git"];
  const deniedTargets = [
    "-c color.ui=false status",
    "-C /tmp status",
    "worktree list",
    "checkout main",
    "stash",
    "pop",
  ];

  for (const option of supportedOptions) {
    for (const target of deniedTargets) {
      await assert.rejects(runBash(`git ${option} ${target}`), {
        message:
          "`git -c`, `git -C`, `git worktree`, `git checkout`, `git stash`, `git pop` commands are not allowed.",
      });
    }
  }
});

test("allows safe Git commands", async () => {
  for (const command of [
    "git status",
    "git --no-pager status",
    "git --git-dir=.git status",
    "git --no-pager --git-dir=.git status",
    "git show checkout",
  ]) {
    await assert.doesNotReject(runBash(command));
  }
});

test("preserves interpreter and text-tool protection", async () => {
  for (const command of ["python script.py", "python3 script.py", "node script.js"]) {
    await assert.rejects(runBash(command), {
      message:
        "Inline script execution with interpreters (python, python3, node) is not allowed.",
    });
  }

  for (const command of ["awk '{print $1}' file", "sed 's/a/b/' file", "perl -e 'print 1'"]) {
    await assert.rejects(runBash(command), {
      message:
        "Inline script execution with text processing tools (awk, sed, perl) is not allowed.",
    });
  }
});
