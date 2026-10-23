/**
 * task_show — detailed view of a single task, including linked zk note content.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "@sinclair/typebox";
import {
  expandTilde,
  formatTaskSummary,
  parseTaskExport,
  type Task,
} from "../tw";
import { UuidSchema } from "../types";
import { readFile } from "node:fs/promises";

export function registerTaskShow(pi: ExtensionAPI) {
  pi.registerTool({
    name: "task_show",
    label: "Task Show",
    description:
      "Show full details of a single TaskWarrior task. If the task has a linked zk note (zknote UDA), the note content is included in the response.",
    promptSnippet: "Show task details and linked zk note",
    promptGuidelines: [
      "Use task_show to inspect a single task in full detail, including its linked zk note.",
      "Always pass a UUID, never an integer ID. Returns all UDAs and the note content if one exists.",
      "Use this before making decisions about a task — the note often contains context and completion criteria.",
    ],
    parameters: Type.Object({
      uuid: UuidSchema,
    }),

    async execute(_toolCallId, params, signal) {
      if (signal?.aborted) throw new Error("Operation aborted");

      // 1. Export the task
      const exportResult = await pi.exec("task", [params.uuid, "export"], {
        signal,
      });
      if (exportResult.code !== 0) {
        throw new Error(
          `Task ${params.uuid} not found (code ${exportResult.code}): ${exportResult.stderr}`,
        );
      }

      const tasks = parseTaskExport(exportResult.stdout);
      const task = tasks[0];
      if (!task) {
        throw new Error(`Task ${params.uuid} returned empty export.`);
      }

      // 2. Get raw export for UDAs not in our typed model
      const rawExport = JSON.parse(exportResult.stdout)[0] as Record<string, unknown>;
      const zknote = typeof rawExport.zknote === "string" ? rawExport.zknote : undefined;

      // 3. Build output sections
      const sections: string[] = [];

      // Task summary
      sections.push("## Task");
      sections.push(formatTaskSummary(task));

      // UDAs (all keys not in our standard task model)
      const knownKeys = new Set([
        "uuid", "description", "status", "project", "priority", "urgency",
        "due", "scheduled", "tags", "start", "end", "depends", "entry", "modified",
        "id",
      ]);
      const udas: string[] = [];
      for (const [key, value] of Object.entries(rawExport)) {
        if (!knownKeys.has(key) && value !== undefined && value !== null && value !== "") {
          const display = Array.isArray(value)
            ? value.join(", ")
            : String(value);
          udas.push(`  ${key}: ${display}`);
        }
      }
      if (udas.length > 0) {
        sections.push("");
        sections.push("## UDAs");
        sections.push(udas.join("\n"));
      }

      // 4. Read zk note if present
      if (zknote) {
        sections.push("");
        sections.push(`## ZK Note: \`${zknote}\``);

        try {
          const notePath = expandTilde(zknote);
          const noteContent = await readFile(notePath, "utf-8");
          sections.push("");
          sections.push(noteContent);
        } catch {
          sections.push("");
          sections.push(`  (note file not found at ${zknote})`);
        }
      }

      return {
        content: [{ type: "text", text: sections.join("\n") }],
        details: {
          uuid: task.uuid,
          task,
          zknote: zknote ?? null,
          hasNote: !!zknote,
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
