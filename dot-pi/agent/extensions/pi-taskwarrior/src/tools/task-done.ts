/**
 * task_done — mark a TaskWarrior task as completed.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { TaskDoneSchema } from "../types";
import { buildDoneArgs, formatTaskSummary, parseTaskExport } from "../tw";

export function registerTaskDone(pi: ExtensionAPI) {
  pi.registerTool({
    name: "task_done",
    label: "Task Done",
    description:
      "Mark a TaskWarrior task as completed. Hooks handle zk note frontmatter sync automatically.",
    promptSnippet: "Mark a task as done",
    promptGuidelines: [
      "Use task_done to complete a task. Always pass a UUID, never an integer ID.",
      "No need to stop first — marking a task done auto-stops it if active.",
      "This is irreversible — the task moves to completed status.",
      "Use task_show to see the Done when checklist, then task_check to mark items the agent completed BEFORE calling task_done.",
      "Hooks automatically sync the linked zk note frontmatter.",
    ],
    parameters: TaskDoneSchema,

    async execute(_toolCallId, params, signal) {
      // If task is active, done implicitly stops it — no extra handling needed.
      const result = await pi.exec("task", buildDoneArgs(params.uuid), { signal });
      if (result.code !== 0) {
        throw new Error(
          `task done failed (code ${result.code}): ${result.stderr}`,
        );
      }

      // Fetch the completed task for confirmation
      const exportResult = await pi.exec(
        "task",
        [params.uuid, "export"],
        { signal },
      );
      if (exportResult.code !== 0) {
        return {
          content: [
            {
              type: "text",
              text: `Task ${params.uuid} marked as completed.`,
            },
          ],
          details: { uuid: params.uuid, status: "completed" },
        };
      }

      const tasks = parseTaskExport(exportResult.stdout);
      const task = tasks[0];
      if (!task) {
        return {
          content: [
            {
              type: "text",
              text: `Task ${params.uuid} marked as completed.`,
            },
          ],
          details: { uuid: params.uuid, status: "completed" },
        };
      }

      return {
        content: [{ type: "text", text: formatTaskSummary(task) }],
        details: { uuid: params.uuid, task },
      };
    },
  });
}
