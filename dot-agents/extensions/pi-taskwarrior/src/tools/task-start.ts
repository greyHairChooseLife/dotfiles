/**
 * task_start — start tracking time on a task.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { TaskStartSchema } from "../types";
import { buildStartArgs, formatTaskSummary, parseTaskExport } from "../tw";

export function registerTaskStart(pi: ExtensionAPI) {
  pi.registerTool({
    name: "task_start",
    label: "Task Start",
    description:
      "Start tracking time on a TaskWarrior task. Only one task can be active at a time — if another task is active, stop it first with task_stop.",
    promptSnippet: "Start tracking time on a task",
    promptGuidelines: [
      "Use task_start to begin working on a task. Always use UUID from task_list.",
      "If another task is currently active, task_start will fail — use task_stop first.",
      "Use task_list to check which task (if any) is currently active.",
    ],
    parameters: TaskStartSchema,

    async execute(_toolCallId, params, signal) {
      const result = await pi.exec("task", buildStartArgs(params.uuid), { signal });
      if (result.code !== 0) {
        throw new Error(
          `task start failed (code ${result.code}): ${result.stderr}`,
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
              text: `Started task ${params.uuid}.`,
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
            { type: "text", text: `Started task ${params.uuid}.` },
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
