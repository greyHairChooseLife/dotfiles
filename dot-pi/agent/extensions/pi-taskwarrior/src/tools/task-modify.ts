/**
 * task_modify — modify TaskWarrior task attributes.
 *
 * If the task is currently active (has a start time), this tool stops it,
 * applies the modification, then restarts it. The stop/restart is transparent
 * to the caller.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { TaskModifySchema } from "../types";
import {
  buildGetAttrArgs,
  buildModifyArgs,
  buildStartArgs,
  buildStopArgs,
  formatTaskSummary,
  parseTaskExport,
} from "../tw";

export function registerTaskModify(pi: ExtensionAPI) {
  pi.registerTool({
    name: "task_modify",
    label: "Task Modify",
    description:
      "Modify a TaskWarrior task's attributes (description, project, priority, due, scheduled, tags). Automatically handles active tasks by stopping before modifying and restarting after.",
    promptSnippet: "Modify a TaskWarrior task",
    promptGuidelines: [
      "Use task_modify to change task attributes. Always pass a UUID, never an integer ID.",
      "To add/remove tags without replacing all: use +tag/-tag directly in the tag list (TW merges).",
      "To clear a date field (due, scheduled), pass an empty string.",
      "Cannot change task status — use task_done or task_delete for that.",
    ],
    parameters: TaskModifySchema,

    async execute(_toolCallId, params, signal) {
      const uuid = params.uuid;

      // Check if task is currently active
      const startResult = await pi.exec("task", buildGetAttrArgs(uuid, "start"), {
        signal,
      });
      const wasActive = startResult.code === 0 && startResult.stdout.trim().length > 0;

      // Stop if active
      if (wasActive) {
        const stopResult = await pi.exec("task", buildStopArgs(uuid), { signal });
        if (stopResult.code !== 0) {
          throw new Error(
            `Failed to stop active task ${uuid}: ${stopResult.stderr}`,
          );
        }
      }

      // Apply modifications
      const args = buildModifyArgs(uuid, {
        description: params.description,
        project: params.project,
        priority: params.priority,
        due: params.due,
        scheduled: params.scheduled,
        tags: params.tags,
      });

      // Handle removeTags separately: append -tag for each
      if (params.removeTags && params.removeTags.length > 0) {
        for (const tag of params.removeTags) {
          args.push(`-${tag}`);
        }
      }

      const modifyResult = await pi.exec("task", args, { signal });
      if (modifyResult.code !== 0) {
        // Try to restart if we stopped earlier
        if (wasActive) {
          await pi.exec("task", buildStartArgs(uuid), { signal });
        }
        throw new Error(
          `task modify failed (code ${modifyResult.code}): ${modifyResult.stderr}`,
        );
      }

      // Restart if was active
      if (wasActive) {
        const restartResult = await pi.exec("task", buildStartArgs(uuid), {
          signal,
        });
        if (restartResult.code !== 0) {
          // Not fatal — modification succeeded, just couldn't restart
        }
      }

      // Fetch updated task
      const exportResult = await pi.exec("task", [uuid, "export"], { signal });
      if (exportResult.code !== 0) {
        return {
          content: [{ type: "text", text: `Task ${uuid} modified.` }],
          details: { uuid },
        };
      }

      const tasks = parseTaskExport(exportResult.stdout);
      const task = tasks[0];
      if (!task) {
        return {
          content: [{ type: "text", text: `Task ${uuid} modified.` }],
          details: { uuid },
        };
      }

      return {
        content: [{ type: "text", text: formatTaskSummary(task) }],
        details: { uuid, task, wasActive, restartFailed: wasActive && !task.start },
      };
    },
  });
}
