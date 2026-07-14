---
name: task-add
description: Create and interview new TaskWarrior tasks with linked zettelkasten notes. Use when the user asks to add, create, or plan a task. Handles context filling, completion criteria, project/priority assignment, and large task splitting. SKIP for modifying or completing existing tasks (task-manage), searching, or general note-taking.
---
# Task Add

Creates a new TaskWarrior task with a linked zk note. The hook system (`on-add.1`)
auto-creates the note from `taskwarrior.md` template; this skill's job is to fill
the empty `## Context` and `## Done when` sections through an interview.

## System


-   **Notebook**: `~/Documents/zk/` (flat, zk notebook root)
-   **Hook**: `on-add.1-create-zknote` auto-creates note with `zknote` UDA
-   **Template**: `.zk/templates/taskwarrior.md` → `## Context` / `## Done when` / `## Log`
-   **UDA**: `zknote` = absolute path to linked note
-   **Frontmatter** (set by hook): `title`, `created`, `updated`, `note-type: taskwarrior`, `task-uuid`, `task-project`, `task-status: pending`, `tags`

## Flow

### When user says "add task" / "create task" / "할 일 추가해줘"

1.  **Interview** - capture these, ask only what's missing:

    | Item | Destination | Infer? |
    |------|------------|--------|
    | **what** (description) | `task add "..."` | From user's request |
    | **why** (context) | note `## Context` | Infer if obvious, ask if ambiguous |
    | **완료조건** (completion criteria) | note `## Done when` | Always ask - minimum 1 checkbox |
    | **when** (due/schedule) | `task add ... due:...` | Ask if time-sensitive, else skip |
    | **project** | `task add ... project:...` | Infer by nature (see below) |

2.  **Execute** - single `task add "description" project:X due:Z`. Hook creates the note.

3.  **Fill the note** - read the note file (path in `zknote` UDA of new task), replace:
    -   `{{content}}` in `## Context` → interview content (1-2 lines for simple tasks, more for complex)
    -   `- [ ]` in `## Done when` → concrete checklist items from interview

### Large tasks → subtasks

When Done when has 3+ independently completable items:

1.  Diagnose: "N independent items - Split (they don't block each other)" or "Sequential (B depends on A)"
2.  Ask: "Split / Sequential / No?"
3.  Never split without explicit confirmation.
4.  **Sequential**: `task add ... depends:<prev-uuid>` chain. Keep original as final step.
5.  **Split**: `task <id> delete rc.confirmation=no`, create N new tasks under same project, each inheriting relevant Context.

## Quirks

| Quirk | Rule |
|-------|------|
| Dashes in project → `-system` parse error | Use underscore: `zksystem` not `zk-system` |
| IDs reassign after done/delete | Always use UUID. After `task add`, read UUID from output and use it. |
| `task add` block on confirmation | Already configured `confirmation=no` |


## Example

User: "nginx access log 분석하는 task 추가해줘"

Agent interviews:
-   Context: 왜 분석하는가?
-   Done when: 무엇을 알아내면 완료인가?
-   Project: `study`
-   Due: 필요 없음

Result:
```bash
task add "nginx access log 분석" project:study
# hook creates note → agent fills Context and Done when
```
