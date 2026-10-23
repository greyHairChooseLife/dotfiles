/**
 * Shared TypeBox schemas and types used across taskwarrior tools.
 */

import { Type } from "@sinclair/typebox";

// --- Reusable partials ---

export const ProjectSchema = Type.Optional(
  Type.String({ description: "Project name. Dashes are auto-converted to underscores." }),
);

export const PrioritySchema = Type.Optional(
  Type.String({ description: "Priority: H (high), M (medium), L (low)" }),
);

export const TagsSchema = Type.Optional(
  Type.Array(Type.String(), { description: "List of tags (without + prefix)" }),
);

export const UuidSchema = Type.String({
  description: "Task UUID (never integer ID). Obtained from task_list, task_add, or task_uuid.",
});

// --- Tool-specific schemas ---

export const TaskAddSchema = Type.Object({
  description: Type.String({ description: "Task description text" }),
  project: ProjectSchema,
  priority: PrioritySchema,
  due: Type.Optional(
    Type.String({ description: "Due date (natural language or ISO, e.g. 'tomorrow', '2026-07-20')" }),
  ),
  scheduled: Type.Optional(
    Type.String({ description: "Scheduled start date (natural or ISO)" }),
  ),
  tags: TagsSchema,
  depends: Type.Optional(
    Type.String({ description: "UUID of a task this task depends on" }),
  ),
});

export const TaskListSchema = Type.Object({
  status: Type.Optional(
    Type.String({ description: "Filter by status: pending, completed, waiting, deleted, recurring" }),
  ),
  project: ProjectSchema,
  search: Type.Optional(
    Type.String({ description: "Search term matched against description (case-insensitive)" }),
  ),
  due: Type.Optional(
    Type.String({ description: "Filter by due date (e.g. 'today', 'tomorrow', '2026-07-20', 'before:2026-07-31', 'after:today'). Passes the value directly as `due:` filter." }),
  ),
  tags: TagsSchema,
  limit: Type.Optional(
    Type.Number({ description: "Max tasks to return (default: all matching)" }),
  ),
});

export const TaskModifySchema = Type.Object({
  uuid: UuidSchema,
  description: Type.Optional(
    Type.String({ description: "New description text (replaces existing)" }),
  ),
  project: ProjectSchema,
  priority: Type.Optional(
    Type.String({ description: "Priority: H (high), M (medium), L (low). Pass empty string to remove." }),
  ),
  due: Type.Optional(
    Type.String({ description: "New due date. Pass empty string to remove." }),
  ),
  scheduled: Type.Optional(
    Type.String({ description: "New scheduled date. Pass empty string to remove." }),
  ),
  tags: Type.Optional(
    Type.Array(Type.String(), { description: "Replacement tag list. CAUTION: this replaces all existing tags." }),
  ),
  removeTags: Type.Optional(
    Type.Array(Type.String(), { description: "Tags to remove (without - prefix)" }),
  ),
});

export const TaskStartSchema = Type.Object({
  uuid: UuidSchema,
});

export const TaskStopSchema = Type.Object({
  uuid: UuidSchema,
});

export const TaskDoneSchema = Type.Object({
  uuid: UuidSchema,
});

export const TaskDeleteSchema = Type.Object({
  uuid: UuidSchema,
});
