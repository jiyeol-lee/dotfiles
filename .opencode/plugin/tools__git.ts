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
            .min(1)
            .max(100)
            .describe("The number of latest commits to retrieve the diff for"),
        },
        async execute(args) {
          const { number_of_commits: numberOfCommits } = args;

          try {
            const result = await $`git diff HEAD~${numberOfCommits}`.text();
            return result;
          } catch (error) {
            return JSON.stringify(
              {
                success: false,
                error: `Failed to retrieve latest commits diff: ${error instanceof Error ? error.message : String(error)}`,
              },
              null,
              2,
            );
          }
        },
      }),
      "tool__git--retrieve-current-branch-diff": tool({
        description:
          "Retrieve the diff of the current branch compared to the main branch in the current Git repository.",
        args: {},
        async execute() {
          try {
            const defaultBranch = (
              await $`basename $(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null) 2>/dev/null`.text()
            ).trim();
            if (!defaultBranch) {
              return JSON.stringify(
                {
                  success: false,
                  error: "Could not determine the default branch name.",
                },
                null,
                2,
              );
            }

            const result = await $`git --no-pager diff ${defaultBranch}`.text();
            return result;
          } catch (error) {
            return JSON.stringify(
              {
                success: false,
                error: `Failed to retrieve current branch diff: ${error instanceof Error ? error.message : String(error)}`,
              },
              null,
              2,
            );
          }
        },
      }),
      "tool__git--status": tool({
        description:
          "Retrieve the current git repository status including staged, unstaged, and untracked files.",
        args: {},
        async execute() {
          try {
            // Get status in porcelain format for parsing
            const status = await $`git status --porcelain`.text();

            // Parse the status into structured output
            const lines = status
              .trim()
              .split("\n")
              .filter((line) => line.length > 0);

            const staged: string[] = [];
            const unstaged: string[] = [];
            const untracked: string[] = [];

            for (const line of lines) {
              const indexStatus = line[0];
              const workTreeStatus = line[1];
              const filePath = line.slice(3);

              // Staged changes (index has changes)
              if (indexStatus !== " " && indexStatus !== "?") {
                staged.push(filePath);
              }
              // Unstaged changes (work tree has changes)
              if (workTreeStatus !== " " && workTreeStatus !== "?") {
                unstaged.push(filePath);
              }
              // Untracked files
              if (indexStatus === "?" && workTreeStatus === "?") {
                untracked.push(filePath);
              }
            }

            return JSON.stringify(
              {
                staged,
                unstaged,
                untracked,
                raw: status,
              },
              null,
              2,
            );
          } catch (error) {
            return JSON.stringify(
              {
                success: false,
                error: `Failed to retrieve git status: ${error instanceof Error ? error.message : String(error)}`,
              },
              null,
              2,
            );
          }
        },
      }),
      "tool__git--commit": tool({
        description: "Create a git commit with the staged changes.",
        args: {
          message: tool.schema
            .string()
            .describe("The commit message (subject line)"),
          body: tool.schema
            .string()
            .optional()
            .describe("Optional extended commit message body"),
        },
        async execute(args) {
          const { message, body } = args;

          try {
            // Validate message is not empty
            if (!message || message.trim().length === 0) {
              return JSON.stringify(
                {
                  success: false,
                  error: "Commit message cannot be empty",
                },
                null,
                2,
              );
            }

            // Check if there are staged changes
            const status = await $`git status --porcelain`.text();
            const hasStagedChanges = status
              .trim()
              .split("\n")
              .some(
                (line) => line.length > 0 && line[0] !== " " && line[0] !== "?",
              );

            if (!hasStagedChanges) {
              return JSON.stringify(
                {
                  success: false,
                  error:
                    "No staged changes to commit. Use tool__git--stage-files first.",
                },
                null,
                2,
              );
            }

            // Create the commit
            let result: string;
            if (body) {
              result = await $`git commit -m ${message} -m ${body}`.text();
            } else {
              result = await $`git commit -m ${message}`.text();
            }

            // Get the commit hash
            const commitHash = (
              await $`git rev-parse --short HEAD`.text()
            ).trim();

            return JSON.stringify(
              {
                success: true,
                commit_hash: commitHash,
                message: message,
                body: body || null,
                output: result,
              },
              null,
              2,
            );
          } catch (error) {
            return JSON.stringify(
              {
                success: false,
                error: `Failed to create commit: ${error instanceof Error ? error.message : String(error)}`,
              },
              null,
              2,
            );
          }
        },
      }),
      "tool__git--stage-files": tool({
        description:
          "Stage specified files for commit. Use '.' to stage all changes.",
        args: {
          files: tool.schema
            .array(tool.schema.string())
            .describe(
              "Array of file paths to stage, or ['.'] to stage all changes",
            ),
        },
        async execute(args) {
          const { files } = args;

          try {
            // Validate files array is not empty
            if (!files || files.length === 0) {
              return JSON.stringify(
                {
                  success: false,
                  error: "No files specified to stage",
                },
                null,
                2,
              );
            }

            // Validate file paths (allow alphanumeric, dash, underscore, dot, slash, and '.')
            for (const file of files) {
              if (file !== "." && !/^[\w\-./]+$/.test(file)) {
                return JSON.stringify(
                  {
                    success: false,
                    error: `Invalid file path: ${file}. Only alphanumeric characters, dashes, underscores, dots, and forward slashes are allowed.`,
                  },
                  null,
                  2,
                );
              }
            }

            // Stage the files
            await $`git add ${files}`.text();

            // Get the updated status to confirm what was staged
            const status = await $`git status --porcelain`.text();
            const stagedFiles = status
              .trim()
              .split("\n")
              .filter(
                (line) => line.length > 0 && line[0] !== " " && line[0] !== "?",
              )
              .map((line) => line.slice(3));

            return JSON.stringify(
              {
                success: true,
                staged_files: stagedFiles,
                message: `Successfully staged ${stagedFiles.length} file(s)`,
              },
              null,
              2,
            );
          } catch (error) {
            return JSON.stringify(
              {
                success: false,
                error: `Failed to stage files: ${error instanceof Error ? error.message : String(error)}`,
              },
              null,
              2,
            );
          }
        },
      }),
      "tool__git--push": tool({
        description:
          "Push the current branch to the remote repository with upstream tracking.",
        args: {},
        async execute() {
          try {
            const result = await $`git push -u origin HEAD`.text();

            return JSON.stringify(
              {
                success: true,
                output: result,
              },
              null,
              2,
            );
          } catch (error) {
            return JSON.stringify(
              {
                success: false,
                error: `Failed to push: ${error instanceof Error ? error.message : String(error)}`,
              },
              null,
              2,
            );
          }
        },
      }),
    },
  };
};
