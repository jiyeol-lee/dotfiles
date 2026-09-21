import { Plugin } from "@opencode/plugin";
import { command } from "../lib/server-tools.ts";
import {
  loadStore,
  paneStateFromSessions,
  parsePaneLine,
  pruneStore,
  saveStore,
  sessionIdFromEvent,
  setPaneState,
  stateFromEvent,
  statusFilePath,
  statusTypeFromEvent,
  type BusEvent,
  type PaneRow,
  type PaneStore,
  type SessionIconState,
} from "../lib/tmux-status.ts";

type Shell = ReturnType<typeof command>;

const paneListFormat =
  "#{window_id}\t#{pane_id}\t#{pane_index}\t#{pane_current_command}\t#{pane_pid}\t#{pane_current_path}";

// Single painter for plugin events, zsh precmd, and the tmux pane-exited hook.
const stripScript = `${process.env.HOME}/dotfiles/scripts/tmux_opencode_pane_strip.sh`;

const listPanes = async (run: Shell): Promise<PaneRow[]> => {
  const result = await run("tmux", ["list-panes", "-a", "-F", paneListFormat]);

  return result
    .split("\n")
    .flatMap((line) => {
      const pane = parsePaneLine(line.trim());
      return pane ? [pane] : [];
    });
};

const parentPid = async (run: Shell, pid: number) => {
  const result = await run("ps", ["-o", "ppid=", "-p", String(pid)]);

  const value = Number(result.trim());
  return Number.isInteger(value) && value > 0 ? value : undefined;
};

/** Walks from this process up the PPID chain until a tmux pane shell matches. */
const findOwnPaneId = async ($: Shell, panes: PaneRow[]) => {
  const paneIdByPid = new Map(panes.map((pane) => [pane.pid, pane.id]));
  let pid: number | undefined = process.pid;

  for (let depth = 0; depth < 16 && pid; depth += 1) {
    const paneId = paneIdByPid.get(pid);
    if (paneId) {
      return paneId;
    }

    pid = await parentPid($, pid);
  }

  return undefined;
};

async function setup(ctx: Plugin.Context) {
  const $ = command(ctx.location.directory);
  const path = statusFilePath();
  const sessions = new Map<string, SessionIconState>();
  let ownPaneId: string | undefined;
  let store: PaneStore = path ? loadStore(path) : {};

  const paint = async () => {
    if (!ownPaneId) {
      return;
    }

    const panes = await listPanes($);
    if (!panes.some((pane) => pane.id === ownPaneId)) {
      return;
    }

    // Merge the on-disk store so sibling opencode panes keep their entries.
    const base = path ? loadStore(path) : store;
    store = setPaneState(
      pruneStore(
        base,
        new Set(panes.map((pane) => pane.id)),
      ),
      ownPaneId,
      paneStateFromSessions(sessions.values()),
    );

    if (path) {
      saveStore(path, store);
    }

    await $(stripScript, []);
  };

  const safePaint = async () => {
    try {
      await paint();
    } catch {
      // tmux may be absent
    }
  };

  const track = async (sessionId: string, state: SessionIconState) => {
    sessions.set(sessionId, state);
    await safePaint();
  };

  try {
    ownPaneId = await findOwnPaneId($, await listPanes($));
    await safePaint();
  } catch {
    // tmux may be absent
  }

  const controller = new AbortController();
  const events = (async () => {
    for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
      const busEvent = event as BusEvent;
      if (event.location && event.location.directory !== ctx.location.directory) continue;
      const sessionId = sessionIdFromEvent(busEvent);
      if (!sessionId) {
        continue;
      }

      if (busEvent.type === "session.deleted") {
        sessions.delete(sessionId);
        await safePaint();
        continue;
      }

      const state = stateFromEvent(
        busEvent.type ?? "",
        statusTypeFromEvent(busEvent),
      );
      if (!state) {
        continue;
      }

      await track(sessionId, state);
    }
  })().catch((error) => {
    if (!controller.signal.aborted) console.error("tmux-status event stream failed", error);
  });
  await ctx.session.hook("prompt", async (event) => {
    await track(event.sessionID, "running");
  });
  return async () => {
    controller.abort();
    await events;
  };
}

export default Plugin.define({ id: "tmux-status", setup });
