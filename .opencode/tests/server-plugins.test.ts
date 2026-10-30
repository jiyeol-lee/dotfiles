import assert from "node:assert/strict";
import test from "node:test";
import type { Plugin } from "@opencode/plugin";
import type { Info } from "@opencode/plugin/promise/tool";
import GhTools from "../plugins/tools__gh.ts";
import { command } from "../lib/server-tools.ts";

test("GH plugin registers the collaborators tool through v2 transforms", async () => {
  const tools: Info[] = [];
  const ctx = {
    location: { directory: process.cwd() },
    tool: { transform: async (callback: (editor: { add: (tool: Info) => void }) => void) => callback({ add: (tool) => { tools.push(tool); } }) },
  } as unknown as Plugin.Context;
  await GhTools.setup(ctx);
  assert.equal(tools.length, 1);
  assert.equal(tools[0].name, "tool__gh--retrieve-repository-collaborators");
  assert.equal(new Set(tools.map((tool) => tool.name)).size, 1);
  for (const tool of tools) {
    assert.ok(tool.description);
    assert.ok("~standard" in tool.input);
  }
});

test("server commands pass text literally and send bodies through stdin", async () => {
  const run = command(process.cwd());
  const text = "'quoted' $(echo unsafe); & | \n--option";
  assert.equal(await run("printf", ["%s", text]), text);
  assert.equal(await run("cat", [], text), text);
  await assert.rejects(run("git", ["not-a-real-git-subcommand"]));
});
