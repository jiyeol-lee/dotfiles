import { Plugin } from "@opencode/plugin";

export default Plugin.define({
  id: "env-protection",
  async setup(ctx) {
    await ctx.tool.hook("execute.before", async (event) => {
      const input = event.input as { path?: string; filePath?: string };
      if (event.tool === "read" && (input.path ?? input.filePath ?? "").includes(".env")) {
        throw new Error("Do not read .env files");
      }
    });
  },
});
