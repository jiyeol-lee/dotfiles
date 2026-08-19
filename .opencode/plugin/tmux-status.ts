import { type Plugin } from "@opencode-ai/plugin";
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
} from "./lib/tmux-status.ts";

type Shell = Parameters<Plugin>[0]["$"];

const paneListFormat =
  "#{window_id}\t#{pane_id}\t#{pane_index}\t#{pane_current_command}\t#{pane_pid}\t#{pane_current_path}";

// Single painter for plugin events, zsh precmd, and the tmux pane-exited hook.
const stripScript = `${process.env.HOME}/dotfiles/scripts/tmux_opencode_pane_strip.sh`;

const listPanes = async ($: Shell): Promise<PaneRow[]> => {
  const result = await $`tmux list-panes -a -F ${paneListFormat}`
    .nothrow()
    .quiet();
  if (result.exitCode !== 0) {
    return [];
  }

  return result
    .text()
    .split("\n")
    .flatMap((line) => {
      const pane = parsePaneLine(line.trim());
      return pane ? [pane] : [];
    });
};

const parentPid = async ($: Shell, pid: number) => {
  const result = await $`ps -o ppid= -p ${pid}`.nothrow().quiet();
  if (result.exitCode !== 0) {
    return undefined;
  }

  const value = Number(result.text().trim());
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

const TmuxStatus: Plugin = async ({ $ }) => {
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

    await $`${stripScript}`.nothrow().quiet();
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

  return {
    event: async ({ event }) => {
      const busEvent = event as unknown as BusEvent;
      const sessionId = sessionIdFromEvent(busEvent);
      if (!sessionId) {
        return;
      }

      if (busEvent.type === "session.deleted") {
        sessions.delete(sessionId);
        await safePaint();
        return;
      }

      const state = stateFromEvent(
        busEvent.type ?? "",
        statusTypeFromEvent(busEvent),
      );
      if (!state) {
        return;
      }

      await track(sessionId, state);
    },
    "chat.message": async (input) => {
      await track(input.sessionID, "running");
    },
    "permission.ask": async (input) => {
      await track(input.sessionID, "ask");
    },
  };
};

export default TmuxStatus;
