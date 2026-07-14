/**
 * TaskWarrior CLI helpers.
 *
 * Pure functions — no pi dependency. All pi.exec calls happen in tool
 * execute() handlers where they have access to ctx.signal.
 */

export interface Task {
  uuid: string;
  description: string;
  status: "pending" | "completed" | "deleted" | "waiting" | "recurring";
  project?: string;
  priority?: "H" | "M" | "L";
  urgency: number;
  due?: string;
  scheduled?: string;
  tags: string[];
  start?: string;
  end?: string;
  depends?: string[];
  entry: string;
  modified: string;
}

export interface TaskListOptions {
  status?: string;
  project?: string;
  search?: string;
  tags?: string[];
  limit?: number;
}

export interface TaskAddOptions {
  project?: string;
  priority?: "H" | "M" | "L";
  due?: string;
  scheduled?: string;
  tags?: string[];
  depends?: string;
}

export interface TaskModifyOptions {
  project?: string;
  priority?: "H" | "M" | "L" | "";
  due?: string | "";
  scheduled?: string | "";
  tags?: string[];
  description?: string;
}

// ---------------------------------------------------------------------------
// Sanitization
// ---------------------------------------------------------------------------

/** TaskWarrior parses dashes as flag prefixes. Replace with underscore. */
export function sanitizeProject(name: string): string {
  return name.replace(/-/g, "_");
}

// ---------------------------------------------------------------------------
// Command builders
// ---------------------------------------------------------------------------

export function buildAddArgs(description: string, opts: TaskAddOptions): string[] {
  const args: string[] = ["add", description];

  if (opts.project) {
    args.push(`project:${sanitizeProject(opts.project)}`);
  }
  if (opts.priority) {
    args.push(`priority:${opts.priority}`);
  }
  if (opts.due) {
    args.push(`due:${opts.due}`);
  }
  if (opts.scheduled) {
    args.push(`scheduled:${opts.scheduled}`);
  }
  if (opts.tags) {
    for (const tag of opts.tags) {
      args.push(`+${tag}`);
    }
  }
  if (opts.depends) {
    args.push(`depends:${opts.depends}`);
  }

  args.push("rc.confirmation=no");
  return args;
}

export function buildListArgs(opts: TaskListOptions): string[] {
  const args: string[] = ["export"];

  // Default to pending tasks unless explicitly overridden
  const status = opts.status || "pending";
  args.push(`status:${status}`);
  if (opts.project) {
    args.push(`project:${sanitizeProject(opts.project)}`);
  }
  if (opts.search) {
    args.push(`/${opts.search}/`);
  }
  if (opts.tags) {
    for (const tag of opts.tags) {
      args.push(`+${tag}`);
    }
  }

  args.push(`rc.verbose:nothing`);

  return args;
}

export function buildModifyArgs(
  uuid: string,
  opts: TaskModifyOptions,
): string[] {
  const args: string[] = [uuid, "modify"];

  if (opts.description !== undefined) {
    args.push(opts.description);
  }
  if (opts.project !== undefined) {
    args.push(`project:${sanitizeProject(opts.project)}`);
  }
  if (opts.priority !== undefined) {
    args.push(`priority:${opts.priority}`);
  }
  if (opts.due !== undefined) {
    // Empty string = remove
    args.push(`due:${opts.due}`);
  }
  if (opts.scheduled !== undefined) {
    args.push(`scheduled:${opts.scheduled}`);
  }
  if (opts.tags !== undefined) {
    for (const tag of opts.tags) {
      args.push(`+${tag}`);
    }
  }

  args.push("rc.confirmation=no");
  return args;
}

export function buildStartArgs(uuid: string): string[] {
  return [uuid, "start"];
}

export function buildStopArgs(uuid: string): string[] {
  return [uuid, "stop"];
}

export function buildDoneArgs(uuid: string): string[] {
  return [uuid, "done", "rc.confirmation=no"];
}

export function buildDeleteArgs(uuid: string): string[] {
  return [uuid, "delete", "rc.confirmation=no"];
}

export function buildGetUuidArgs(id: string): string[] {
  return ["_get", `${id}.uuid`];
}

export function buildGetAttrArgs(uuid: string, attr: string): string[] {
  return ["_get", `${uuid}.${attr}`];
}

// ---------------------------------------------------------------------------
// Output parsing
// ---------------------------------------------------------------------------

/** Extract numeric ID from "Created task N." output */
export function parseCreatedId(stdout: string): string | null {
  const match = stdout.match(/Created task (\d+)\./);
  return match ? match[1] : null;
}

/** Extract UUID from `task _get N.uuid` output (single line) */
export function parseUuid(stdout: string): string {
  return stdout.trim();
}

/** Parse `task export` JSON array into Task objects */
export function parseTaskExport(stdout: string): Task[] {
  if (!stdout.trim()) return [];
  const raw = JSON.parse(stdout);
  const tasks: Task[] = [];

  for (const t of raw) {
    tasks.push({
      uuid: t.uuid,
      description: t.description,
      status: t.status,
      project: t.project || undefined,
      priority: t.priority || undefined,
      urgency: t.urgency ?? 0,
      due: t.due || undefined,
      scheduled: t.scheduled || undefined,
      tags: parseTagList(t.tags),
      start: t.start || undefined,
      end: t.end || undefined,
      depends: parseTagList(t.depends),
      entry: t.entry,
      modified: t.modified,
    });
  }

  return tasks;
}

function parseTagList(val: unknown): string[] {
  if (!val) return [];
  if (Array.isArray(val)) return val.map(String);
  return [String(val)];
}

// ---------------------------------------------------------------------------
// Output formatting
// ---------------------------------------------------------------------------

function pad(s: string, width: number): string {
  return s.length >= width ? s : s + " ".repeat(width - s.length);
}

const PRIORITY_MAP: Record<string, string> = { H: "H", M: "M", L: "L" };

const STATUS_ABBREV: Record<string, string> = {
  pending: "PEND",
  completed: "DONE",
  deleted: "DEL",
  waiting: "WAIT",
  recurring: "RECUR",
};

export function formatTaskTable(tasks: Task[]): string {
  if (tasks.length === 0) return "No tasks found.";

  const rows: string[] = [];

  // Header
  const uuidWidth = 8;
  const descWidth = 50;
  const projWidth = 20;
  const statusWidth = 6;
  const priWidth = 4;
  const urgWidth = 5;

  const header =
    pad("UUID", uuidWidth) +
    " " +
    pad("DESCRIPTION", descWidth) +
    " " +
    pad("PROJECT", projWidth) +
    " " +
    pad("STATUS", statusWidth) +
    " " +
    pad("PRI", priWidth) +
    " " +
    pad("URG", urgWidth);
  rows.push(header);

  // Separator
  const sep = "-".repeat(
    uuidWidth + descWidth + projWidth + statusWidth + priWidth + urgWidth + 5,
  );
  rows.push(sep);

  for (const t of tasks) {
    const shortUuid = t.uuid.slice(0, uuidWidth);
    const desc = t.description.length > descWidth
      ? t.description.slice(0, descWidth - 1) + "…"
      : t.description;
    const proj = (t.project || "").length > projWidth
      ? (t.project || "").slice(0, projWidth - 1) + "…"
      : (t.project || "");
    const status = STATUS_ABBREV[t.status] ?? t.status.toUpperCase();
    const pri = PRIORITY_MAP[t.priority ?? ""] ?? " ";
    const urg = String(Math.round(t.urgency)).slice(0, urgWidth);

    rows.push(
      pad(shortUuid, uuidWidth) +
        " " +
        pad(desc, descWidth) +
        " " +
        pad(proj, projWidth) +
        " " +
        pad(status, statusWidth) +
        " " +
        pad(pri, priWidth) +
        " " +
        pad(urg, urgWidth),
    );
  }

  return rows.join("\n");
}

export function formatTaskSummary(t: Task): string {
  const lines: string[] = [
    `UUID: ${t.uuid}`,
    `Description: ${t.description}`,
    `Status: ${t.status}`,
    `Urgency: ${t.urgency}`,
  ];
  if (t.project) lines.push(`Project: ${t.project}`);
  if (t.priority) lines.push(`Priority: ${t.priority}`);
  if (t.due) lines.push(`Due: ${t.due}`);
  if (t.scheduled) lines.push(`Scheduled: ${t.scheduled}`);
  if (t.tags.length > 0) lines.push(`Tags: ${t.tags.join(", ")}`);
  if (t.depends && t.depends.length > 0) lines.push(`Depends: ${t.depends.join(", ")}`);
  if (t.start) lines.push(`Active: started ${t.start}`);
  return lines.join("\n");
}
