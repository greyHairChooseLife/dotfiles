/**
 * task_stop — stop tracking time on the active task.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { TaskStopSchema } from "../types";
import { buildStopArgs, formatTaskSummary, parseTaskExport } from "../tw";

export function registerTaskStop(pi: ExtensionAPI) {
  pi.registerTool({
    name: "task_stop",
    label: "Task Stop",
    description:
      "Stop tracking time on a TaskWarrior task. Only has effect if the task is currently active.",
    promptSnippet: "Stop tracking time on a task",
    promptGuidelines: [
      "Use task_stop to stop working on a task. Always use UUID from task_list.",
      "This is safe to call on non-active tasks — it just returns the current state.",
      "Use task_list to check which task is currently active.",
    ],
    parameters: TaskStopSchema,

    async execute(_toolCallId, params, signal) {
      const result = await pi.exec("task", buildStopArgs(params.uuid), { signal });
      if (result.code !== 0) {
        throw new Error(
          `task stop failed (code ${result.code}): ${result.stderr}`,
        );
      }

      // Fetch updated task
      const exportResult = await pi.exec("task", [params.uuid, "export"], {
        signal,
      });
      if (exportResult.code !== 0) {
        return {
          content: [
            {
              type: "text",
              text: `Stopped task ${params.uuid}.`,
            },
          ],
          details: { uuid: params.uuid },
        };
      }

      const tasks = parseTaskExport(exportResult.stdout);
      const task = tasks[0];
      if (!task) {
        return {
          content: [
            { type: "text", text: `Stopped task ${params.uuid}.` },
          ],
          details: { uuid: params.uuid },
        };
      }

      return {
        content: [{ type: "text", text: formatTaskSummary(task) }],
        details: { uuid: params.uuid, task },
      };
    },
  });
}
