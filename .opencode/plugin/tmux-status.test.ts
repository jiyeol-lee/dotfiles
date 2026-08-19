import assert from "node:assert/strict";
import test from "node:test";
import {
  paneStateFromSessions,
  parsePaneLine,
  pruneStore,
  sessionIdFromEvent,
  setPaneState,
  stateFromEvent,
} from "./lib/tmux-status.ts";

test("maps session and ask events to icon states", () => {
  assert.equal(stateFromEvent("session.created"), "idle");
  assert.equal(stateFromEvent("session.status", "busy"), "running");
  assert.equal(stateFromEvent("session.status", "retry"), "running");
  assert.equal(stateFromEvent("session.status", "idle"), "done");
  assert.equal(stateFromEvent("permission.updated"), "ask");
  assert.equal(stateFromEvent("permission.asked"), "ask");
  assert.equal(stateFromEvent("question.asked"), "ask");
  assert.equal(stateFromEvent("permission.replied"), "running");
  assert.equal(stateFromEvent("question.replied"), "running");
  assert.equal(stateFromEvent("question.rejected"), "running");
  assert.equal(stateFromEvent("session.updated"), null);
});

test("reads session id from info or sessionID", () => {
  assert.equal(
    sessionIdFromEvent({
      properties: { info: { id: "ses_info" } },
    }),
    "ses_info",
  );
  assert.equal(
    sessionIdFromEvent({
      properties: { sessionID: "ses_direct" },
    }),
    "ses_direct",
  );
});

test("resolves the pane state by highest priority across sessions", () => {
  assert.equal(paneStateFromSessions(["idle"]), "idle");
  assert.equal(paneStateFromSessions(["idle", "done"]), "done");
  assert.equal(paneStateFromSessions(["done", "running"]), "running");
  assert.equal(paneStateFromSessions(["running", "ask", "idle"]), "ask");
  assert.equal(paneStateFromSessions([]), "idle");
});

test("prunes records for panes that disappeared", () => {
  const pruned = pruneStore(
    {
      "%1": { state: "done", updated: 1 },
      "%9": { state: "running", updated: 2 },
    },
    new Set(["%1"]),
  );

  assert.deepEqual(pruned, { "%1": { state: "done", updated: 1 } });
});

test("writes pane records immutably", () => {
  const store = setPaneState({}, "%2", "ask", 5);

  assert.deepEqual(store, { "%2": { state: "ask", updated: 5 } });
});

test("parses pane list lines", () => {
  assert.deepEqual(
    parsePaneLine("@0\t%2\t2\topencode\t89151\t/Users/jiyeollee/dotfiles"),
    {
      windowId: "@0",
      id: "%2",
      index: 2,
      command: "opencode",
      pid: 89151,
      path: "/Users/jiyeollee/dotfiles",
    },
  );
  assert.equal(parsePaneLine("@0\t%2\t2\topencode\tbad\t/tmp"), undefined);
});
