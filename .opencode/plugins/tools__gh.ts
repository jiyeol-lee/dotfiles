import { Plugin } from "@opencode/plugin";
import { command, tool } from "../lib/server-tools.ts";

export default Plugin.define({
  id: "tools-gh",
  async setup(ctx) {
    const run = command(ctx.location.directory);
    const repository = async () => JSON.parse(await run("gh", ["repo", "view", "--json", "owner,name"])) as { owner: { login: string }; name: string };
    const tools = {
      "tool__gh--retrieve-pull-request-info": tool({
        description:
          "Retrieve detailed information about a GitHub pull request, including its state, title, body, comments, reviews, and review threads. `pull_request_number` is optional and defaults to the current branch's PR if not provided. By default, resolved review threads are excluded, but can be included by setting `with_resolved` to true. Use this tool when you want to get comprehensive information about a specific pull request in the current repository.",
        args: {
          pull_request_number: tool.schema
            .number()
            .optional()
            .describe(
              "The pull request number to retrieve info for (default: current branch's PR)",
            ),
          with_resolved: tool.schema
            .boolean()
            .optional()
            .default(false)
            .describe(
              "Whether to include resolved review threads (default: false)",
            ),
        },
        async execute(args) {
          const {
            pull_request_number: pullRequestNumber,
            with_resolved: withResolved,
          } = args;

          try {
            const pullRequestNumberArg =
              pullRequestNumber ??
              Number(
                (await run("gh", ["pr", "view", "--json", "number", "-q", ".number"])).trim(),
              );

            const repo = await repository();
            const result = JSON.parse(await run("gh", ["api", "graphql", "-f", `query=
              query($owner: String!, $name: String!, $number: Int!) {
                repository(owner: $owner, name: $name) {
                  pullRequest(number: $number) {
                    state
                    title
                    body
                    comments(last: 20) {
                      nodes {
                        url
                        author { login }
                        body
                      }
                    }
                    reviews(last: 10) {
                      nodes {
                        url
                        author { login }
                        body
                        state
                      }
                    }
                    reviewThreads(last: 50) {
                      nodes {
                        path
                        line
                        isResolved
                        comments(last: 10) {
                          nodes {
                            body
                            author { login }
                            url
                          }
                        }
                      }
                    }
                  }
                }
              }`, "-F", `owner=${repo.owner.login}`, "-F", `name=${repo.name}`, "-F", `number=${pullRequestNumberArg}`]));
            if (!withResolved) {
              result.data.repository.pullRequest.reviewThreads.nodes = result.data.repository.pullRequest.reviewThreads.nodes.filter((thread: { isResolved: boolean }) => !thread.isResolved);
            }
            return JSON.stringify(result, null, 2);
          } catch (error) {
            return JSON.stringify(
              {
                success: false,
                error: `Failed to retrieve pull request info: ${error instanceof Error ? error.message : String(error)}`,
              },
              null,
              2,
            );
          }
        },
      }),
      "tool__gh--retrieve-repository-collaborators": tool({
        description:
          "Retrieve a list of collaborators for the current GitHub repository. Use this tool to get information about the users who have access to the repository, including their GitHub usernames and names. Use this tool when you want to see who has access to the repository and their roles.",
        args: {},
        async execute() {
          try {
            const repo = await repository();
            const result = JSON.parse(await run("gh", ["api", "graphql", "-f", `query=
              query($owner: String!, $name: String!) {
                repository(owner: $owner, name: $name) {
                  collaborators(first: 100) {
                    edges {
                      node {
                        login
                        name
                      }
                    }
                  }
                }
              }`, "-F", `owner=${repo.owner.login}`, "-F", `name=${repo.name}`]));

            return JSON.stringify(result.data.repository.collaborators.edges.map((edge: { node: { login: string; name: string | null } }) => edge.node), null, 2);
          } catch (error) {
            return JSON.stringify(
              {
                success: false,
                error: `Failed to retrieve repository collaborators: ${error instanceof Error ? error.message : String(error)}`,
              },
              null,
              2,
            );
          }
        },
      }),
      "tool__gh--create-pull-request": tool({
        description:
          "Create a new draft pull request in the current GitHub repository. `title` and `body` are required, while `reviewers` is optional and can be a list of GitHub usernames to request reviews from. Use this tool when you want to create a new pull request for your changes, allowing you to specify the title, description, and reviewers for the pull request.",
        args: {
          title: tool.schema.string().describe("The title of the pull request"),
          body: tool.schema
            .string()
            .describe("The body/description of the pull request"),
          reviewers: tool.schema
            .array(tool.schema.string())
            .optional()
            .describe("List of reviewers' GitHub usernames"),
        },
        async execute(args) {
          const { title, body, reviewers } = args;

          try {
            const reviewersList = reviewers?.join(",");

            const result = await run("gh", ["pr", "create", "--draft", "--title", title, "--assignee", "@me", "--body-file", "-", ...(reviewersList ? ["--reviewer", reviewersList] : [])], body);
            return result;
          } catch (error) {
            return JSON.stringify(
              {
                success: false,
                error: `Failed to create pull request: ${error instanceof Error ? error.message : String(error)}`,
              },
              null,
              2,
            );
          }
        },
      }),
      "tool__gh--edit-pull-request": tool({
        description:
          "Edit an existing pull request in the current GitHub repository. `pull_request_number` is required to identify which pull request to edit. `title`, `body`, and `reviewers` are optional fields that can be updated. If `reviewers` is provided, it will add the specified GitHub usernames as reviewers to the pull request. Use this tool when you want to modify the details of an existing pull request, such as changing its title, description, or adding reviewers.",
        args: {
          pull_request_number: tool.schema
            .number()
            .describe("The pull request number to edit"),
          title: tool.schema
            .string()
            .optional()
            .describe("The new title of the pull request"),
          body: tool.schema
            .string()
            .optional()
            .describe("The new body/description of the pull request"),
          reviewers: tool.schema
            .array(tool.schema.string())
            .optional()
            .describe("List of reviewers' GitHub usernames"),
        },
        async execute(args) {
          const {
            pull_request_number: pullRequestNumber,
            title,
            body,
            reviewers,
          } = args;

          try {
            const reviewersList = reviewers?.join(",");

            let result: string;

            if (body !== undefined && title !== undefined) {
              result =
                await run("gh", ["pr", "edit", String(pullRequestNumber), "--title", title, "--body-file", "-"], body);
            } else if (body !== undefined) {
              result =
                await run("gh", ["pr", "edit", String(pullRequestNumber), "--body-file", "-"], body);
            } else if (title !== undefined) {
              result =
                await run("gh", ["pr", "edit", String(pullRequestNumber), "--title", title]);
            } else {
              result = "No changes specified";
            }

            if (reviewersList) {
              await run("gh", ["pr", "edit", String(pullRequestNumber), "--add-reviewer", reviewersList]);
            }

            return result;
          } catch (error) {
            return JSON.stringify(
              {
                success: false,
                error: `Failed to edit pull request: ${error instanceof Error ? error.message : String(error)}`,
              },
              null,
              2,
            );
          }
        },
      }),
      "tool__gh--retrieve-pull-request-diff": tool({
        description:
          "Retrieve the diff of a GitHub pull request in the current repository. `pull_request_number` is required to specify which pull request's diff to retrieve. Use this tool to view the changes introduced by a pull request in a unified diff format. Use this tool when you want to analyze the code changes made in a pull request.",
        args: {
          pull_request_number: tool.schema
            .number()
            .describe("The pull request number to retrieve the diff for"),
        },
        async execute(args) {
          const { pull_request_number: pullRequestNumber } = args;

          try {
            const result = await run("gh", ["pr", "diff", String(pullRequestNumber)]);
            return result;
          } catch (error) {
            return JSON.stringify(
              {
                success: false,
                error: `Failed to retrieve pull request diff: ${error instanceof Error ? error.message : String(error)}`,
              },
              null,
              2,
            );
          }
        },
      }),
      "tool__gh--retrieve-repository-dependabot-alerts": tool({
        description:
          "Retrieve a list of Dependabot alerts for the current GitHub repository. `state` is an optional filter to specify the state of the alerts to retrieve (e.g., 'open', 'closed', 'dismissed'). `severity` is another optional filter to specify the severity level of the alerts (e.g., 'low', 'medium', 'high', 'critical'). By default, it retrieves open alerts of all severity levels. Use this tool when you want to monitor and manage security vulnerabilities in your repository's dependencies.",
        args: {
          state: tool.schema
            .string()
            .optional()
            .describe(
              "Filter alerts by state (e.g., 'open', 'closed', 'dismissed')",
            ),
          severity: tool.schema
            .string()
            .optional()
            .describe(
              "Filter alerts by severity (e.g., 'low', 'medium', 'high', 'critical')",
            ),
        },
        async execute(args) {
          const { state = "open", severity } = args;

          try {
            const repo = await repository();
            const queryParams = new URLSearchParams();
            if (state) {
              queryParams.append("state", state);
            }
            if (severity) {
              queryParams.append("severity", severity);
            }
            const result =
              await run("gh", ["api", `/repos/${repo.owner.login}/${repo.name}/dependabot/alerts?${queryParams.toString()}`]);
            return result;
          } catch (error) {
            return JSON.stringify(
              {
                success: false,
                error: `Failed to retrieve Dependabot alerts: ${error instanceof Error ? error.message : String(error)}`,
              },
              null,
              2,
            );
          }
        },
      }),
    };
    await ctx.tool.transform((editor) => {
      editor.add({ name: "tool__gh--retrieve-pull-request-info", ...tools["tool__gh--retrieve-pull-request-info"] });
      editor.add({ name: "tool__gh--retrieve-repository-collaborators", ...tools["tool__gh--retrieve-repository-collaborators"] });
      editor.add({ name: "tool__gh--create-pull-request", ...tools["tool__gh--create-pull-request"] });
      editor.add({ name: "tool__gh--edit-pull-request", ...tools["tool__gh--edit-pull-request"] });
      editor.add({ name: "tool__gh--retrieve-pull-request-diff", ...tools["tool__gh--retrieve-pull-request-diff"] });
      editor.add({ name: "tool__gh--retrieve-repository-dependabot-alerts", ...tools["tool__gh--retrieve-repository-dependabot-alerts"] });
    });
  },
});
