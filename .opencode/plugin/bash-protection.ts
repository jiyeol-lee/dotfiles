import { type Plugin } from "@opencode-ai/plugin";

const deniedGitSubcommands = new Set(["worktree", "checkout", "stash", "pop"]);
const isDeniedGitOption = (token: string) =>
  token === "-c" ||
  token.startsWith("-c=") ||
  token === "-C" ||
  token.startsWith("-C");

const isDeniedGitInvocation = (command: string) => {
  const tokens = command.trim().split(/\s+/);
  const gitIndex = tokens.findIndex(
    (token) => token === "git" || token.endsWith("/git"),
  );

  if (gitIndex === -1) {
    return false;
  }

  if (tokens.slice(gitIndex + 1).some(isDeniedGitOption)) {
    return true;
  }

  let index = gitIndex + 1;
  while (index < tokens.length) {
    const token = tokens[index];

    if (token === "--no-pager") {
      index += 1;
      continue;
    }

    if (token === "--git-dir") {
      index += 2;
      continue;
    }

    if (token.startsWith("--git-dir=")) {
      index += 1;
      continue;
    }

    return deniedGitSubcommands.has(token);
  }

  return false;
};

export const BashProtection: Plugin = async ({}) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "bash") {
        const command = output.args.command || "";

        if (/\\[ \t]*(?:\r?\n|$)/.test(command)) {
          throw new Error(
            "Backslash line continuations and trailing backslashes are not allowed in bash commands.",
          );
        }

        if (/[;&|\r\n]/.test(command)) {
          throw new Error(
            "Shell separator and control characters (;, &, |, carriage return, and newline) are not allowed.",
          );
        }

        if (/(python3?|node)\b/.test(command)) {
          throw new Error(
            "Inline script execution with interpreters (python, python3, node) is not allowed.",
          );
        }

        if (/(awk|sed|perl)\b/.test(command)) {
          throw new Error(
            "Inline script execution with text processing tools (awk, sed, perl) is not allowed.",
          );
        }

        if (isDeniedGitInvocation(command)) {
          throw new Error(
            "`git -c`, `git -C`, `git worktree`, `git checkout`, `git stash`, `git pop` commands are not allowed.",
          );
        }
      }
    },
  };
};
