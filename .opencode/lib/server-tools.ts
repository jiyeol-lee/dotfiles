import { execFile } from "node:child_process";
import { z } from "zod";

// Execute argv directly, without a shell or interpolation of model-provided text.
export const command = (cwd: string) => (file: string, args: string[], stdin?: string): Promise<string> =>
  new Promise((resolve, reject) => {
    const child = execFile(file, args, { cwd, maxBuffer: 16 * 1024 * 1024 }, (error, stdout, stderr) => {
      if (error) reject(new Error(stderr.trim() || error.message));
      else resolve(stdout);
    });
    child.stdin?.on("error", () => {});
    child.stdin?.end(stdin);
  });

export const tool = Object.assign(
  <S extends z.ZodRawShape>(definition: {
    description: string;
    args: S;
    execute: (input: z.infer<z.ZodObject<S>>) => Promise<string>;
  }) => ({
    description: definition.description,
    input: z.object(definition.args),
    execute: async (input: z.infer<z.ZodObject<S>>) => ({ content: await definition.execute(input) }),
  }),
  { schema: z },
);
