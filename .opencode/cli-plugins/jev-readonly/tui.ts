import { Plugin } from "@opencode/plugin/tui";
import { JevReadonlyRpc } from "../../lib/jev-readonly-rpc.ts";

export default Plugin.define({
  id: "jev-readonly",
  setup(context) {
    const rpc = context.client.rpc(JevReadonlyRpc);
    return rpc.events.on("approved", (event) => {
      const location = context.location ?? context.data.location.default();
      if (
        event.location.directory !== location.directory ||
        event.location.workspaceID !== location.workspaceID
      )
        return;
      try {
        context.ui.toast.show({
          title: "Jev auto-approved",
          message: event.data.command,
          variant: "success",
          duration: 3000,
          sessionID: event.data.sessionID,
        });
      } catch {
        // A failed toast must not end the approval event subscription.
      }
    });
  },
});
