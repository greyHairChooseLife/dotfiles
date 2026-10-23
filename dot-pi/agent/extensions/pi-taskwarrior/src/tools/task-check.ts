/**
 * task_check — mark specific Done when checklist items as complete in a task's zk note.
 *
 * Reads the "## Done when" section from the linked zk note and flips
 * matching - [ ] items to - [x]. Only the items specified by the caller
 * are checked off — the agent infers which criteria were met.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "@sinclair/typebox";
import { UuidSchema } from "../types";
import { expandTilde, parseTaskExport } from "../tw";
import { readFile, writeFile } from "node:fs/promises";

interface ZkSection {
  start: number;
  end: number;
  content: string;
}

function findDoneWhenSection(fullContent: string): ZkSection | null {
  const match = fullContent.match(/^## Done when\s*$/m);
  if (!match || match.index === undefined) return null;

  const sectionStart = match.index;
  const afterHeader = fullContent.slice(sectionStart + match[0].length);
  const nextHeaderMatch = afterHeader.match(/^## /m);
  const sectionEnd = nextHeaderMatch
    ? sectionStart + match[0].length + nextHeaderMatch.index!
    : fullContent.length;

  return {
    start: sectionStart,
    end: sectionEnd,
    content: fullContent.slice(sectionStart, sectionEnd),
  };
}

function parseChecklist(sectionContent: string): Array<{ line: string; checked: boolean }> {
  const lines = sectionContent.split("\n");
  return lines
    .map((line) => {
      const unchecked = line.match(/^- \[ \] (.+)/);
      if (unchecked) return { line, checked: false };
      const checked = line.match(/^- \[x\] (.+)/i);
      if (checked) return { line, checked: true };
      return null;
    })
    .filter((item): item is { line: string; checked: boolean } => item !== null);
}

export function registerTaskCheck(pi: ExtensionAPI) {
  pi.registerTool({
    name: "task_check",
    label: "Task Check",
    description:
      "Mark specific Done when checklist items as complete in a task's linked zk note. Pass the exact text (or substring) of items the agent believes are completed. Does NOT modify the task itself — use task_done for that.",
    promptSnippet: "Check off Done when items in a task's zk note",
    promptGuidelines: [
      "Use task_check BEFORE task_done to record progress on Done when items.",
      "First use task_show to see the checklist items.",
      "Pass items as substrings — 'implement X' matches '- [ ]   implement X feature'.",
      "Only check items the agent actually completed. Skip items that weren't done.",
      "Safe to call multiple times — skips already-checked items.",
    ],
    parameters: Type.Object({
      uuid: UuidSchema,
      items: Type.Array(Type.String(), {
        description:
          "One or more Done when item texts to check off. Each is matched as a substring against checklist lines. Only unchecked items (- [ ]) are flipped to - [x].",
      }),
    }),

    async execute(_toolCallId, params, signal) {
      if (signal?.aborted) throw new Error("Operation aborted");

      // 1. Get zknote path from task export
      const exportResult = await pi.exec("task", [params.uuid, "export"], {
        signal,
      });
      if (exportResult.code !== 0) {
        throw new Error(
          `Task ${params.uuid} not found (code ${exportResult.code}): ${exportResult.stderr}`,
        );
      }

      const rawExport = JSON.parse(exportResult.stdout)[0] as Record<string, unknown>;
      const zknote = typeof rawExport.zknote === "string" ? rawExport.zknote : undefined;
      if (!zknote) {
        return {
          content: [
            {
              type: "text",
              text: `Task ${params.uuid} has no linked zk note (no zknote UDA). Nothing to check.`,
            },
          ],
          details: { uuid: params.uuid, checked: 0 },
        };
      }

      // 2. Read the note
      const notePath = expandTilde(zknote);
      let fullContent: string;
      try {
        fullContent = await readFile(notePath, "utf-8");
      } catch {
        return {
          content: [
            {
              type: "text",
              text: `ZK note not found at ${notePath}. Nothing to check.`,
            },
          ],
          details: { uuid: params.uuid, zknote, checked: 0 },
        };
      }

      // 3. Find Done when section
      const section = findDoneWhenSection(fullContent);
      if (!section) {
        return {
          content: [
            {
              type: "text",
              text: "No '## Done when' section found in the zk note.",
            },
          ],
          details: { uuid: params.uuid, zknote, checked: 0 },
        };
      }

      // 4. Match items to checklist lines
      const checklist = parseChecklist(section.content);
      let checked = 0;
      const done: string[] = [];
      const notFound: string[] = [];

      for (const item of params.items) {
        const target = item.trim().toLowerCase();
        let matched = false;

        for (const entry of checklist) {
          if (entry.checked) continue; // already checked
          if (entry.line.toLowerCase().includes(target)) {
            // Flip - [ ] to - [x]
            const checkedLine = entry.line.replace("- [ ]", "- [x]");
            fullContent = fullContent.replace(entry.line, checkedLine);
            entry.checked = true;
            checked++;
            done.push(checkedLine.trim());
            matched = true;
            break;
          }
        }

        if (!matched) {
          notFound.push(item);
        }
      }

      // 5. Write back if any changes
      if (checked > 0) {
        await writeFile(notePath, fullContent, "utf-8");
      }

      const lines: string[] = [];
      if (done.length > 0) {
        lines.push(`Checked off ${done.length} item${done.length === 1 ? "" : "s"}:`);
        for (const d of done) {
          lines.push(`  ${d}`);
        }
      }
      if (notFound.length > 0) {
        if (done.length > 0) lines.push("");
        lines.push(`${notFound.length} item${notFound.length === 1 ? "" : "s"} not found (already checked or no match):`);
        for (const n of notFound) {
          lines.push(`  "${n}"`);
        }
      }
      if (checked === 0 && notFound.length === 0) {
        lines.push("No items to check (checklist is empty or all items already checked).");
      }

      return {
        content: [{ type: "text", text: lines.join("\n") }],
        details: { uuid: params.uuid, zknote, checked, notFound: notFound.length },
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
      if (expanded) {
        text.setText(`\n${output}`);
        return text;
      }

      // Show just the summary line + first checked item
      const summary = lines[0] ?? "";
      const first = lines.length > 1 ? ` ${lines[1]}` : "";
      let content = `\n${summary}${first}`;
      if (lines.length > 2) {
        content += theme.fg("muted", `\n... (${lines.length - 2} more lines)`);
      }
      text.setText(content);
      return text;
    },
  });
}
