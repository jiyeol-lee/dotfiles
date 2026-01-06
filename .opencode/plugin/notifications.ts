import { type Plugin } from "@opencode-ai/plugin";

export const NotificationPlugin: Plugin = async ({ $, client }) => {
  return {
    event: async ({ event }) => {
      switch (event.type) {
        // Handle session errors with type-specific messages
        case "session.error": {
          const { error, sessionID } = event.properties;

          // Skip MessageAbortedError - user-initiated abort
          if (error?.name === "MessageAbortedError") {
            return;
          }

          // Fetch session data to get the title
          const session = sessionID
            ? await (async () => {
                try {
                  const { data } = await client.session.get({
                    path: { id: sessionID },
                  });
                  return data;
                } catch {
                  // Session may have been deleted or network error - continue without title
                  return undefined;
                }
              })()
            : undefined;

          // Map error types to user-friendly messages
          const errorMessages: Record<string, string> = {
            ProviderAuthError: "Authentication error",
            APIError: "API error occurred",
            MessageOutputLengthError: "Output length exceeded",
            UnknownError: "An unknown error occurred",
          };

          // Get error message with fallback
          const errorMessage = error?.name
            ? (errorMessages[error.name] ?? "An unexpected error occurred")
            : "An unexpected error occurred";

          // Format notification with session title if available
          const notification = session?.title
            ? `Session '${session.title}': ${errorMessage}`
            : errorMessage;

          // Sanitize notification to prevent shell injection
          const sanitizedNotification = notification.replace(/[`$"'\\]/g, "");
          await $`say ${sanitizedNotification}`;
          break;
        }

        case "session.idle": {
          const sessionID = event.properties.sessionID;

          const result = await (async () => {
            try {
              const { data: session } = await client.session.get({
                path: { id: sessionID },
              });
              const { data: messages } = await client.session.messages({
                path: { id: sessionID },
                query: { limit: 5 },
              });
              return { session, messages };
            } catch {
              // API error - skip notification
              return undefined;
            }
          })();

          if (!result) return;
          const { session, messages } = result;

          if (session) {
            if (session.parentID === undefined) {
              // Get the last 3 assistant messages
              const lastAssistantMessages = messages
                ?.filter((m) => m.info.role === "assistant")
                .slice(-3);

              // Check if ANY of the last 3 assistant messages is waiting for response
              const isWaiting = lastAssistantMessages?.some((message) => {
                const textPart = message.parts.find(
                  (p) => p.type === "text" && !p.synthetic,
                );
                return (
                  textPart?.type === "text" &&
                  isWaitingForResponse(textPart.text)
                );
              });

              if (isWaiting) {
                await $`say "I'm waiting for your response"`;
              } else {
                await $`say "I've finished the job"`;
              }
            }
          }
          break;
        }
      }
    },
  };
};

function isWaitingForResponse(text: string): boolean {
  const lastParagraph =
    text.split("\n").filter(Boolean).pop()?.toLowerCase() ?? "";

  const questionPatterns = [
    // Asking for permission/approval
    /do you want[^?!.]*\?/i,
    /do you approve[^?!.]*\?/i,
    /should i[^?!.]*\?/i,
    /would you like[^?!.]*\?/i,
    /shall i[^?!.]*\?/i,
    /may i[^?!.]*\?/i,
    /want me to[^?!.]*\?/i,
    /like me to[^?!.]*\?/i,
    /need me to[^?!.]*\?/i,
    // Asking for confirmation
    /are you sure[^?!.]*\?/i,
    /is that (ok|okay|correct|right)[^?!.]*\?/i,
    /does that (work|sound|look)[^?!.]*\?/i,
    /make sense[^?!.]*\?/i,
    // Asking for choice/preference
    /which (one|option|approach|file|path|directory)[^?!.]*\?/i,
    /what would you[^?!.]*\?/i,
    /how would you[^?!.]*\?/i,
    /what do you (think|prefer)[^?!.]*\?/i,
    /any (thoughts|preference|objections)[^?!.]*\?/i,
    // Asking before proceeding
    /before (i|we) (proceed|continue|start)[^?!.]*\?/i,
    /ready (for|to)[^?!.]*\?/i,
    /proceed with[^?!.]*\?/i,
    /go ahead[^?!.]*\?/i,
    /move forward[^?!.]*\?/i,
    // Clarification questions
    /(can|could) you (clarify|specify|provide|confirm)[^?!.]*\?/i,
    /what (is|are) (your|the)[^?!.]*\?/i,
  ];

  const statementPatterns = [
    // Choice headers (before numbered lists)
    /would you like me to( either)?[:\s]*$/i,
    /here are (your |the |some )?(options|choices)[:\s]*$/i,
    /(i|we) (can|could)( either)?[:\s]*$/i,
    // Explicit requests for input
    /let me know (what|which|how|if|when|your)[^?]+\.$/i,
    /please (choose|select|pick|specify|confirm)[^?]+\.$/i,
    // Terminal choice phrases
    /the choice is yours\.$/i,
    /it'?s (up to you|your call)\.$/i,
  ];

  return (
    questionPatterns.some((p) => p.test(lastParagraph)) ||
    statementPatterns.some((p) => p.test(lastParagraph))
  );
}
