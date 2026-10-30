import { Plugin } from "@opencode/plugin";
import { command, tool } from "../lib/server-tools.ts";

export default Plugin.define({
  id: "tools-gh",
  async setup(ctx) {
    const run = command(ctx.location.directory);
    const repository = async () =>
      JSON.parse(await run("gh", ["repo", "view", "--json", "owner,name"])) as {
        owner: { login: string };
        name: string;
      };
    await ctx.tool.transform((editor) => {
      editor.add({
        name: "tool__gh--retrieve-repository-collaborators",
        ...tool({
          description:
            "Retrieve a list of collaborators for the current GitHub repository. Use this tool to get information about the users who have access to the repository, including their GitHub usernames and names. Use this tool when you want to see who has access to the repository and their roles.",
          args: {},
          async execute() {
            try {
              const repo = await repository();
              const result = JSON.parse(
                await run("gh", [
                  "api",
                  "graphql",
                  "-f",
                  `query=
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
              }`,
                  "-F",
                  `owner=${repo.owner.login}`,
                  "-F",
                  `name=${repo.name}`,
                ]),
              );

              return JSON.stringify(
                result.data.repository.collaborators.edges.map(
                  (edge: { node: { login: string; name: string | null } }) =>
                    edge.node,
                ),
                null,
                2,
              );
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
      });
    });
  },
});
