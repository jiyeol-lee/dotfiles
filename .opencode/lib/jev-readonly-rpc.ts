import { Rpc } from "@opencode/plugin/rpc";
import { z } from "zod";

export const JevReadonlyRpc = Rpc.define({
  id: "jev-readonly",
  methods: {},
  events: {
    approved: {
      schema: z.object({ command: z.string(), sessionID: z.string() }),
    },
  },
});
