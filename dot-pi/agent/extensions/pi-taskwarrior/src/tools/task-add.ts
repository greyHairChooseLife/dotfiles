/**
 * task_add — create a new TaskWarrior task.
 *
 * Hooks (on-add) fire automatically when `task add` is called, creating
 * a linked zk note if configured.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { TaskAddSchema } from "../types";
import {
  buildAddArgs,
  buildGetUuidArgs,
  formatTaskSummary,
  parseCreatedId,
  parseTaskExport,
  parseUuid,
} from "../tw";

export function registerTaskAdd(pi: ExtensionAPI) {
  pi.registerTool({
    name: "task_add",
    label: "Task Add",
    description:
      "Create a new TaskWarrior task. Hooks auto-create a linked zk note. Returns the new task UUID and summary.",
    promptSnippet: "Create a new TaskWarrior task",
    promptGuidelines: [
      "Use task_add to create tasks. Prefer this over raw `task add` bash calls.",
      "Project names must use underscores, not dashes (dashes are auto-sanitized).",
      "Use task_list to find existing task UUIDs for the depends field. If the user refers to a dependency by integer ID, use task_uuid to resolve it first.",
      "Due and scheduled dates accept natural language like 'tomorrow', 'friday', or ISO dates.",
    ],
    parameters: TaskAddSchema,

    async execute(_toolCallId, params, signal) {
      const args = buildAddArgs(params.description, {
        project: params.project,
        priority: params.priority,
        due: params.due,
        scheduled: params.scheduled,
        tags: params.tags,
        depends: params.depends,
      });

      const result = await pi.exec("task", args, { signal });
      if (result.code !== 0) {
        throw new Error(`task add failed (code ${result.code}): ${result.stderr}`);
      }

      // Parse the numeric ID from output
      const taskId = parseCreatedId(result.stdout);
      if (!taskId) {
        throw new Error(
          `Could not parse task ID from output: ${result.stdout}`,
        );
      }

      // Get the UUID
      const uuidResult = await pi.exec("task", buildGetUuidArgs(taskId), {
        signal,
      });
      if (uuidResult.code !== 0) {
        throw new Error(
          `Could not get UUID for task ${taskId}: ${uuidResult.stderr}`,
        );
      }
      const uuid = parseUuid(uuidResult.stdout);

      // Fetch full task details for confirmation
      const exportResult = await pi.exec("task", [uuid, "export"], { signal });
      if (exportResult.code !== 0) {
        // Still succeed — just return what we have
        return {
          content: [{ type: "text", text: `Task created.\nUUID: ${uuid}` }],
          details: { uuid },
        };
      }

      const tasks = parseTaskExport(exportResult.stdout);
      const task = tasks[0];
      if (!task) {
        return {
          content: [{ type: "text", text: `Task created.\nUUID: ${uuid}` }],
          details: { uuid },
        };
      }

      return {
        content: [{ type: "text", text: formatTaskSummary(task) }],
        details: { uuid, task },
      };
    },
  });
}
