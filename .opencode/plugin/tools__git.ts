import { tool, type Plugin } from "@opencode-ai/plugin";

export const ToolsGitPlugin: Plugin = async ({ $ }) => {
  return {
    tool: {
      "tool__git--retrieve-latest-n-commits-diff": tool({
        description:
          "Retrieve the diff of the latest N commits in the current Git repository.",
        args: {
          number_of_commits: tool.schema
            .number()
            .describe("The number of latest commits to retrieve the diff for"),
        },
        async execute(args) {
          const { number_of_commits: numberOfCommits } = args;
          try {
            const result = await $`git diff HEAD~${numberOfCommits}`.text();
            return result;
          } catch (error) {
            throw new Error(`Failed to retrieve latest commits diff: ${error}`);
          }
        },
      }),
      "tool__git--retrieve-currernt-branch-diff": tool({
        description:
          "Retrieve the diff of the current branch compared to the main branch in the current Git repository.",
        args: {},
        async execute() {
          try {
            const defaultBranch =
              await $`basename $(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null) 2>/dev/null`.text();
            if (!defaultBranch) {
              throw new Error("Could not determine the default branch name.");
            }
            await $`git add -N .`.text(); // start to track all files without staging changes

            const result = await $`git --no-pager diff ${defaultBranch}`.text();
            return result;
          } catch (error) {
            throw new Error(`Failed to retrieve current branch diff: ${error}`);
          }
        },
      }),
    },
  };
};
