import { type Plugin, tool } from "@opencode-ai/plugin";

export const CustomToolsPlugin: Plugin = async ({ $ }) => {
  return {
    tool: {
      tools__task_add: tool({
        description: "Add a new task to the task list.",
        args: {
          description: tool.schema.string(),
        },
        async execute(args) {
          const { description } = args;

          const result = await $`task add ${description}`.text();
          return result;
        },
      }),
      tools__task_get: tool({
        description: "Get the task information by identifier.",
        args: {
          identifier: tool.schema
            .string()
            .regex(/^\d+$/, "Identifier must be a numeric string."),
        },
        async execute(args) {
          const { identifier } = args;

          const result = await $`task info ${identifier}`.text();
          return result;
        },
      }),
      tools__task_mark_done: tool({
        description: "Mark a task as done in the task list.",
        args: {
          identifier: tool.schema
            .string()
            .regex(/^\d+$/, "Identifier must be a numeric string."),
        },
        async execute(args) {
          const { identifier } = args;

          const result = await $`task done ${identifier}`.text();
          return result;
        },
      }),
    },
  };
};
