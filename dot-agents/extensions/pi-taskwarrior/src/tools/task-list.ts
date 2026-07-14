/**
 * task_list — list/search TaskWarrior tasks.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { TaskListSchema } from "../types";
import {
  buildListArgs,
  formatTaskTable,
  parseTaskExport,
} from "../tw";

export function registerTaskList(pi: ExtensionAPI) {
  pi.registerTool({
    name: "task_list",
    label: "Task List",
    description:
      "List or search TaskWarrior tasks with optional filters. Returns a compact table with UUID, description, project, status, priority, urgency.",
    promptSnippet: "List or search TaskWarrior tasks",
    promptGuidelines: [
      "Use task_list to find task UUIDs before modifying, completing, or deleting.",
      "Filter by project, status, due, tags, or search term. Combine filters.",
      "Defaults to pending tasks. Pass status:completed or status:waiting to see others.",
      "Use search to find tasks by keyword in descriptions.",
      "Use due to filter by date (e.g. 'today', 'tomorrow', 'before:2026-07-31').",
    ],
    parameters: TaskListSchema,

    async execute(_toolCallId, params, signal) {
      const args = buildListArgs({
        status: params.status,
        project: params.project,
        search: params.search,
        due: params.due,
        tags: params.tags,
        limit: params.limit,
      });

      const result = await pi.exec("task", args, { signal });
      if (result.code !== 0) {
        throw new Error(`task export failed (code ${result.code}): ${result.stderr}`);
      }

      const tasks = parseTaskExport(result.stdout);

      // Apply client-side limit if specified (TW export has no native limit)
      const limited = params.limit && params.limit > 0
        ? tasks.slice(0, params.limit)
        : tasks;

      const table = formatTaskTable(limited);

      const info = `Total: ${tasks.length} task${tasks.length === 1 ? "" : "s"}` +
        (limited.length < tasks.length ? ` (showing first ${limited.length})` : "");

      return {
        content: [{ type: "text", text: `${table}\n\n${info}` }],
        details: {
          tasks: limited,
          totalCount: tasks.length,
          shownCount: limited.length,
        },
      };
    },

    renderResult(result, { expanded }, theme, context) {
      const text = (context.lastComponent as Text | undefined) ?? new Text("", 0, 0);
      const output = result.content?.find((c: { type: string }) => c.type === "text")?.text as string ?? "";
      if (!output) {
        text.setText(theme.fg("muted", "No output"));
        return text;
      }

      const lines = output.split("\n");
      const maxLines = expanded ? lines.length : 5;
      const display = lines.slice(0, maxLines).join("\n");
      let content = `\n${display}`;
      if (!expanded && lines.length > maxLines) {
        content += theme.fg("muted", `\n... (${lines.length - maxLines} more lines)`);
      }
      text.setText(content);
      return text;
    },
  });
}
