/**
 * task_delete — delete a TaskWarrior task permanently.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { TaskDeleteSchema } from "../types";
import { buildDeleteArgs } from "../tw";

export function registerTaskDelete(pi: ExtensionAPI) {
  pi.registerTool({
    name: "task_delete",
    label: "Task Delete",
    description:
      "Permanently delete a TaskWarrior task. Hooks handle zk note cleanup automatically. This is irreversible.",
    promptSnippet: "Delete a task permanently",
    promptGuidelines: [
      "Use task_delete to remove a task. Always pass a UUID, never an integer ID.",
      "This is IRREVERSIBLE — the task and its linked zk note are removed.",
      "No need to stop first — delete auto-stops if the task is active.",
      "Before deleting, consider using task_check to mark any remaining Done when items.",
      "Consider using task_done if you only want to archive the task.",
    ],
    parameters: TaskDeleteSchema,

    async execute(_toolCallId, params, signal) {
      const result = await pi.exec("task", buildDeleteArgs(params.uuid), {
        signal,
      });
      if (result.code !== 0) {
        throw new Error(
          `task delete failed (code ${result.code}): ${result.stderr}`,
        );
      }

      return {
        content: [
          {
            type: "text",
            text: `Task ${params.uuid} has been permanently deleted.`,
          },
        ],
        details: { uuid: params.uuid, status: "deleted" },
      };
    },
  });
}
