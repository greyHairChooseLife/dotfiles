/**
 * task_delete — delete a TaskWarrior task permanently.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { TaskDeleteSchema } from "../types";
import { buildDeleteArgs, buildStopArgs } from "../tw";

export function registerTaskDelete(pi: ExtensionAPI) {
  pi.registerTool({
    name: "task_delete",
    label: "Task Delete",
    description:
      "Permanently delete a TaskWarrior task. Hooks handle zk note cleanup automatically. This is irreversible.",
    promptSnippet: "Delete a task permanently",
    promptGuidelines: [
      "Use task_delete to remove a task. Always use UUID from task_list.",
      "This is IRREVERSIBLE — the task and its linked zk note are removed.",
      "If the task is active, it is stopped automatically before deletion.",
      "Consider using task_done if you only want to archive the task.",
    ],
    parameters: TaskDeleteSchema,

    async execute(_toolCallId, params, signal) {
      // Stop if active — delete on active task fails
      await pi.exec("task", buildStopArgs(params.uuid), { signal });
      // Ignore stop errors — task might not be active

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
