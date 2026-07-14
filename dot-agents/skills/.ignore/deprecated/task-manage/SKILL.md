---
name: task-manage
description: Manage existing TaskWarrior tasks — search, modify, complete, delete, and log progress. Use when the user asks to view task lists, change task attributes, mark tasks done, delete tasks, or record progress on a task note. SKIP for creating new tasks.
---
# Task Manage

Manage existing TaskWarrior tasks. Hooks auto-sync frontmatter on modify/done/delete;
this skill handles the CLI commands and progress logging to the linked zk note.

## System

-   Notebook: `~/Documents/zk/` (flat, zk notebook root)
-   UDA: `zknote` = absolute path to linked note
-   Hooks: `on-modify.1` (timespent), `on-modify.2` (frontmatter sync), `on-modify.3` (dunst)
-   Timespent: accumulated `HH:MM:SS`, displayed as human-friendly shorthand

## Log progress

Progress entries go to the note's `## Log` section. To log progress, read the task note from
`zknote` UDA, append to `## Log`:

**Format**: `-   YYYY-MM-DD HH:MM — message`

## Quirks

| Quirk | Rule |
|-------|------|
| Dashes in project names → `-system` parse error | Avoid dashes, use underscore. |
| `done` consumed as description | Separate: modify first, then `task <id> done`. |
| `delete`/`stop` block on stdin | Always `rc.confirmation=no`. |
| Can't modify while active | `task <id> stop` first, then modify. |
| **IDs are reassigned** | UUID only is stable. Re-resolve after any done/delete. Use `task /keyword/ list` to find again. |
| Hooks manage frontmatter | Never manually edit `task-uuid`, `task-project`, `task-status` in the note. |
| Cannot modify while active | `task <id> stop` first if needed. |


## Attached files

Place files in `~/Documents/zk/_attachments/`. Reference from note with wiki links:
```markdown
![[../_attachments/screenshot.png]]
```
