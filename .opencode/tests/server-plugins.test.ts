import assert from "node:assert/strict";
import test from "node:test";
import type { Plugin } from "@opencode/plugin";
import type { Info } from "@opencode/plugin/promise/tool";
import EnvProtection from "../plugins/env-protection.ts";
import GitTools from "../plugins/tools__git.ts";
import GhTools from "../plugins/tools__gh.ts";
import { command } from "../lib/server-tools.ts";

test("env protection handles v2 path and legacy filePath inputs", async () => {
  let before!: (event: { tool: string; input: unknown }) => Promise<void>;
  await EnvProtection.setup({
    tool: { hook: async (_name: string, callback: typeof before) => { before = callback; } },
  } as unknown as Plugin.Context);
  for (const input of [{ path: "/project/.env" }, { filePath: "/project/.env.local" }]) {
    await assert.rejects(before({ tool: "read", input }), /Do not read .env files/);
  }
  await assert.doesNotReject(before({ tool: "read", input: { path: "README.md" } }));
  await assert.doesNotReject(before({ tool: "grep", input: { path: ".env" } }));
});

test("Git and GH plugins register all tools through v2 transforms", async () => {
  const tools: Info[] = [];
  const ctx = {
    location: { directory: process.cwd() },
    tool: { transform: async (callback: (editor: { add: (tool: Info) => void }) => void) => callback({ add: (tool) => { tools.push(tool); } }) },
  } as unknown as Plugin.Context;
  await GitTools.setup(ctx);
  await GhTools.setup(ctx);
  assert.equal(tools.length, 9);
  assert.equal(new Set(tools.map((tool) => tool.name)).size, 9);
  for (const tool of tools) {
    assert.ok(tool.description);
    assert.ok("~standard" in tool.input);
  }
  const commit = tools.find((tool) => tool.name === "tool__git--commit")!;
  const result = await commit.execute({ message: " " }, {} as never);
  assert.deepEqual(JSON.parse(result.content as string), { success: false, error: "Commit message cannot be empty" });
  const stage = tools.find((tool) => tool.name === "tool__git--stage-files")!;
  const invalid = await stage.execute({ files: ["$(touch unsafe)"] }, {} as never);
  assert.equal(JSON.parse(invalid.content as string).success, false);
});

test("server commands pass text literally and send bodies through stdin", async () => {
  const run = command(process.cwd());
  const text = "'quoted' $(echo unsafe); & | \n--option";
  assert.equal(await run("printf", ["%s", text]), text);
  assert.equal(await run("cat", [], text), text);
  await assert.rejects(run("git", ["not-a-real-git-subcommand"]));
});
