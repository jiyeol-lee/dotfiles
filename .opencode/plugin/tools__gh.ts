import { tool, type Plugin } from "@opencode-ai/plugin";

export const ToolsGhPlugin: Plugin = async ({ $ }) => {
  return {
    tool: {
      "tool__gh--retrieve-pull-request-info": tool({
        description:
          "Retrieve detailed information about a GitHub pull request, including its state, title, body, comments, reviews, and review threads. If no pull request number is provided, it retrieves info for the current branch's pull request.",
        args: {
          pull_request_number: tool.schema
            .number()
            .optional()
            .describe("The pull request number to retrieve info for"),
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
              (await $`gh pr view --json number -q .number`).json();

            const result = await $`gh api graphql -f query='
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
              }' \
                -F owner="$(gh repo view --json owner -q .owner.login)" \
                -F name="$(gh repo view --json name -q .name)" \
                -F number=${pullRequestNumberArg} \
                | jq '.data.repository.pullRequest.reviewThreads.nodes |= map(select(.isResolved == ${withResolved}))'`.text();
            return result;
          } catch (error) {
            throw new Error(`Failed to retrieve pull request info: ${error}`);
          }
        },
      }),
      "tool__gh--retrieve-repository-collaborators": tool({
        description:
          "Retrieve a list of collaborators for the current GitHub repository.",
        args: {},
        async execute() {
          try {
            const result = await $`gh api graphql -f query='
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
              }' \
                -F owner="$(gh repo view --json owner -q .owner.login)" \
                -F name="$(gh repo view --json name -q .name)" \
                | jq '[.data.repository.collaborators.edges[].node | {login, name}]'`.text();

            return result;
          } catch (error) {
            throw new Error(
              `Failed to retrieve repository collaborators: ${error}`,
            );
          }
        },
      }),
      "tool__gh--create-pull-request": tool({
        description:
          "Create a new pull request in the current GitHub repository.",
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
            const reviewersArg = reviewers
              ? `--reviewer ${reviewers.join(",")}`
              : "";

            const result =
              await $`gh pr create --title "${title}" --body "${body}" ${reviewersArg} --json url | jq -r .url`.text();
            return result;
          } catch (error) {
            throw new Error(`Failed to create pull request: ${error}`);
          }
        },
      }),
      "tool__gh--edit-pull-request": tool({
        description:
          "Edit an existing pull request in the current GitHub repository.",
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
          const { pull_request_number: pullRequestNumber, title, body } = args;

          try {
            const titleArg = title ? `--title "${title}"` : "";
            const bodyArg = body ? `--body "${body}"` : "";
            const reviewersArg = args.reviewers
              ? `--reviewer ${args.reviewers.join(",")}`
              : "";

            const result =
              await $`gh pr edit ${pullRequestNumber} ${titleArg} ${bodyArg} ${reviewersArg} --json url | jq -r .url`.text();
            return result;
          } catch (error) {
            throw new Error(`Failed to edit pull request: ${error}`);
          }
        },
      }),
      "tool__git--retrieve-pull-request-diff": tool({
        description:
          "Retrieve the diff of a GitHub pull request in the current repository.",
        args: {
          pull_request_number: tool.schema
            .number()
            .describe("The pull request number to retrieve the diff for"),
        },
        async execute(args) {
          const { pull_request_number: pullRequestNumber } = args;

          try {
            const result = await $`gh pr diff ${pullRequestNumber}`.text();
            return result;
          } catch (error) {
            throw new Error(`Failed to retrieve pull request diff: ${error}`);
          }
        },
      }),
    },
  };
};
