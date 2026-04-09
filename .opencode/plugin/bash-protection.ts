import { type Plugin } from "@opencode-ai/plugin";

export const BashProtection: Plugin = async ({}) => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "bash") {
        const command = (output.args.command || "").trimStart();
        if (/^(python3?|node)\b/.test(command)) {
          throw new Error(
            "Inline script execution with interpreters (python, python3, node) is not allowed. Use dedicated tools, skills, or project-configured commands instead.",
          );
        }
      }
    },
  };
};
