/**
 * task_uuid — resolve an integer TaskWarrior ID to its UUID.
 *
 * The user may refer to tasks by their short integer ID (e.g. "task 37").
 * This tool resolves that integer to the canonical UUID so the AI can
 * use UUID-based tools for all subsequent operations.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "@sinclair/typebox";
import { buildGetUuidArgs, parseUuid } from "../tw";

export function registerTaskUuid(pi: ExtensionAPI) {
  pi.registerTool({
    name: "task_uuid",
    label: "Task UUID",
    description: "Resolve an integer TaskWarrior ID (e.g. '37') to its UUID. Use this when the user refers to a task by its integer ID.",
    promptSnippet: "Resolve integer TaskWarrior ID to UUID",
    promptGuidelines: [
      "When the user says 'task N' (e.g. 'task 37'), N is the integer TaskWarrior ID. Use task_uuid to get the UUID first.",
      "Always pass UUIDs, never integer IDs, to all other task tools.",
    ],
    parameters: Type.Object({
      id: Type.String({
        description: "Integer TaskWarrior ID (e.g. '37') that the user referred to directly",
      }),
    }),

    async execute(_toolCallId, params, signal) {
      const result = await pi.exec("task", buildGetUuidArgs(params.id), { signal });
      if (result.code !== 0) {
        throw new Error(
          `Could not resolve task ID ${params.id} (code ${result.code}): ${result.stderr}`,
        );
      }

      const uuid = parseUuid(result.stdout);
      if (!uuid) {
        throw new Error(`Task ID ${params.id} returned empty UUID.`);
      }

      return {
        content: [
          {
            type: "text",
            text: `Task ${params.id} → UUID: ${uuid}`,
          },
        ],
        details: { id: params.id, uuid },
      };
    },

    renderResult(result, _options, theme, _context) {
      const text = new Text("", 0, 0);
      const output = result.content?.[0]?.text ?? "";
      if (!output) {
        text.setText(theme.fg("muted", "No output"));
        return text;
      }
      text.setText(`\n${theme.fg("success", "✓")} ${output}`);
      return text;
    },
  });
}
