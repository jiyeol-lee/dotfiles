import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

export type SessionIconState = "idle" | "running" | "ask" | "done";

export type PaneRecord = {
  state: SessionIconState;
  updated: number;
};

export type PaneStore = Record<string, PaneRecord>;

export type BusEvent = {
  type?: string;
  properties?: Record<string, unknown>;
};

const statusFileName = "tmux-status.json";

/** Returns the runtime JSON path. Empty when XDG_RUNTIME_DIR is unset. */
export const statusFilePath = (runtimeDir = process.env.XDG_RUNTIME_DIR) => {
  if (!runtimeDir) {
    return "";
  }

  return join(runtimeDir, "opencode", statusFileName);
};

/** Maps a bus event to the next icon state. Returns null when the event is ignored. */
export const stateFromEvent = (
  type: string,
  statusType?: string,
): SessionIconState | null => {
  if (type === "session.created") {
    return "idle";
  }

  if (type === "session.status") {
    if (statusType === "busy" || statusType === "retry") {
      return "running";
    }

    if (statusType === "idle") {
      return "done";
    }
  }

  if (
    type === "permission.asked" ||
    type === "permission.updated" ||
    type === "question.asked"
  ) {
    return "ask";
  }

  if (
    type === "permission.replied" ||
    type === "question.replied" ||
    type === "question.rejected"
  ) {
    return "running";
  }

  return null;
};

const asRecord = (value: unknown): Record<string, unknown> | undefined => {
  if (value && typeof value === "object" && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
};

const stringField = (
  record: Record<string, unknown> | undefined,
  key: string,
) => {
  const value = record?.[key];
  return typeof value === "string" && value.length > 0 ? value : undefined;
};

/** Reads session id from common event payload shapes. */
export const sessionIdFromEvent = (event: BusEvent) => {
  const properties = event.properties;
  return (
    stringField(properties, "sessionID") ??
    stringField(asRecord(properties?.info), "id") ??
    stringField(asRecord(properties?.session), "id")
  );
};

export const statusTypeFromEvent = (event: BusEvent) => {
  const status = asRecord(event.properties?.status);
  return stringField(status, "type");
};

/** Writes one pane record into the store. */
export const setPaneState = (
  store: PaneStore,
  paneId: string,
  state: SessionIconState,
  now = Date.now(),
): PaneStore => ({
  ...store,
  [paneId]: { state, updated: now },
});

/** Drops records for panes that no longer exist. */
export const pruneStore = (
  store: PaneStore,
  paneIds: Set<string>,
): PaneStore =>
  Object.fromEntries(
    Object.entries(store).filter(([paneId]) => paneIds.has(paneId)),
  );

const statePriority: Record<SessionIconState, number> = {
  idle: 0,
  done: 1,
  running: 2,
  ask: 3,
};

/** Resolves one pane icon from the states of all sessions sharing a process. */
export const paneStateFromSessions = (
  states: Iterable<SessionIconState>,
): SessionIconState => {
  let best: SessionIconState | undefined;

  for (const state of states) {
    if (!best || statePriority[state] > statePriority[best]) {
      best = state;
    }
  }

  return best ?? "idle";
};

export const loadStore = (path: string): PaneStore => {
  try {
    return JSON.parse(readFileSync(path, "utf8")) as PaneStore;
  } catch {
    return {};
  }
};

export const saveStore = (path: string, store: PaneStore) => {
  mkdirSync(join(path, ".."), { recursive: true });
  writeFileSync(path, `${JSON.stringify(store)}\n`);
};

export type PaneRow = {
  windowId: string;
  id: string;
  index: number;
  command: string;
  pid: number;
  path: string;
};

export const parsePaneLine = (line: string): PaneRow | undefined => {
  const [windowId, id, index, command, pid, ...pathParts] = line.split("\t");
  const path = pathParts.join("\t");
  const pidNumber = Number(pid);

  if (
    !windowId ||
    !id ||
    !index ||
    command === undefined ||
    !Number.isInteger(pidNumber) ||
    !path
  ) {
    return;
  }

  return {
    windowId,
    id,
    index: Number(index),
    command,
    pid: pidNumber,
    path,
  };
};
