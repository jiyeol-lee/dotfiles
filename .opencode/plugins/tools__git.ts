import { Plugin } from "@opencode/plugin";
import { command, tool } from "../lib/server-tools.ts";

export default Plugin.define({
  id: "tools-git",
  async setup(ctx) {
    const run = command(ctx.location.directory);
    const tools = {
      "tool__git--commit": tool({
        description:
          "Create a git commit with the staged changes. `message` is a required argument for the commit message (subject line), and `body` is an optional argument for an extended commit message body. Use this tool when you have staged changes and want to create a commit.",
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
            const status = await run("git", ["status", "--porcelain"]);
            const hasStagedChanges = status
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
              result = await run("git", ["commit", "-m", message, "-m", body]);
            } else {
              result = await run("git", ["commit", "-m", message]);
            }

            // Get the commit hash
            const commitHash = (
              await run("git", ["rev-parse", "--short", "HEAD"])
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
          "Stage specified files for commit. Use '.' to stage all changes. `files` is a required argument that accepts an array of file paths to stage, or ['.'] to stage all changes. File paths should be relative to the repository root and can include alphanumeric characters, dashes, underscores, dots, and forward slashes. Use this tool when you want to stage specific files or all changes before committing.",
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
            await run("git", ["add", "--", ...files]);

            // Get the updated status to confirm what was staged
            const status = await run("git", ["status", "--porcelain"]);
            const stagedFiles = status
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
          "Push the current branch to the remote repository with upstream tracking. Use this tool when you want to push your commits to the remote repository",
        args: {},
        async execute() {
          try {
            const result = await run("git", ["push", "-u", "origin", "HEAD"]);

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
    };
    await ctx.tool.transform((editor) => {
      editor.add({ name: "tool__git--commit", ...tools["tool__git--commit"] });
      editor.add({ name: "tool__git--stage-files", ...tools["tool__git--stage-files"] });
      editor.add({ name: "tool__git--push", ...tools["tool__git--push"] });
    });
  },
});
