---
name: task
description: Task management via TaskWarrior CLI. Use when the user asks to view, add, complete, or modify tasks. Handles project filtering, due dates, priorities, tags, and task-linked zettelkasten notes. Integrates with taskwarrior-tui + hooks + zk note system.
---

# Task

## System Overview

- **TaskWarrior CLI** (`task`) — core task management
- **taskwarrior-tui** — terminal UI (interactive, human-only — you never open it)
- **Hooks** — auto-run on add/modify (documented below, you don't invoke them)
- **Zettelkasten** — each task gets a linked markdown note in `~/Documents/zk/`

### Hooks (transparent, just know their effects)

| Hook | What it does |
|------|-------------|
| `on-add.1-create-zknote-with-resource` | Sets `zk` and `resources` UDAs with paths. For recurring tasks, copies from parent. |
| `on-add.2-add-default-project` | Defaults project to `inbox` if unset |
| `on-modify.1-record-time-spent` | Accumulates `timespent` UDA on start/stop (`HH:MM:SS`) |
| `on-modify.2-sync-zknote-status` | When task completes/deletes: tags the zk note with `taskwarrior-completed` or `taskwarrior-deleted` |

### Custom UDAs

| UDA | Type | Purpose |
|-----|------|---------|
| `zk` | string | Path to linked markdown note. Directory initially, becomes `.md` file after first open. |
| `resources` | string | Path to attached files directory (`~/.tasks-resources/<uuid>/`) |
| `timespent` | string | Accumulated time (`HH:MM:SS`), auto-tracked via start/stop |

### Projects

```
business, inbox, job, note-taking, side-project, study, zksystem, 미래지식융합학회
```

Default: `inbox` (hook-enforced). Unknown projects are valid — they get created as used.

---

## TW Quirks (know these)

| Quirk | Example | Rule |
|-------|---------|------|
| **Dashes in project names** | `project:zk-system` → TW parses as `-system` | Avoid dashes. Use underscore or concatenate (`zksystem`). |
| **`done` consumed as description** | `task 31 modify desc:"X" done` → desc becomes "done" | Always separate: modify first, then `task <id> done`. |
| **Delete/stop needs confirmation** | `task 31 delete` blocks on stdin | Always add `rc.confirmation=no`. |
| **Can't modify while active** | `task <id> modify ...` fails if task is started | `task <id> stop` first, then modify. |
| **Modify after completion** | `task <id> modify description:"X"` works on completed tasks | Completion is reversible for metadata changes. |

---

## Commands

### Viewing

```bash
task next                               # Actionable (pending + ready)
task list                               # All pending
task summary                            # Project breakdown with counts
task project:<name> list                # By project
task +<tag> list                        # With tag
task +OVERDUE list                      # Overdue
task +DUETODAY list                     # Due today
task due.by:eow list                    # Due this week
task <id> info                          # Full details (UDAs, annotations, timestamps)
task export                             # JSON dump (all tasks)
```

### Adding

```bash
task add "description"                                    # Defaults to inbox
task add "description" project:side-project               # With project (no dashes!)
task add "description" due:tomorrow priority:H             # With due + priority
task add "description" +bug +frontend                      # With tags
task add "description" depends:<id>                        # With dependency
```

### Modifying

```bash
task <id> start                           # Start time tracking
task <id> stop                            # Stop time tracking (modify after)
task <id> modify project:<name>           # Change project
task <id> modify due:<date>               # Change due date
task <id> modify priority:H               # Priority: H, M, L, or empty to clear
task <id> modify +<tag>                   # Add tag
task <id> modify -<tag>                   # Remove tag
task <id> modify description:"new"        # Change description (quotes required)
task <id> annotate "text"                 # Add timestamped annotation
task <id> done                            # Mark complete (separate command!)
task <id> delete rc.confirmation=no       # Mark deleted (with no prompt)
```

---

## Task Notes (zk)

Every task has a linked zk note. Use the helper script:

```bash
$HOME/.agents/skills/task/scripts/tw-note.sh <uuid-or-id>                # Read the note
$HOME/.agents/skills/task/scripts/tw-note.sh <uuid-or-id> --edit "text"   # Append to the note (creates if needed)
```

When the user says "record X about task Y" or "write a note for task Y", use `--edit`.

### Note rename/move workflow

When you need to rename a task note (change type prefix, title, or move it), do NOT use `mv` directly. The permission system requires proper handling. Manual steps:

1.  Edit frontmatter: change `type`, `title`, `tags`, `description` as needed
2.  Rename the file: update the type prefix in filename (e.g., `fleeting_` → `reference_`)
3.  Update the task's `zk` UDA: `task <id> modify zk:<new-absolute-path>`
4.  Optionally mark complete: `task <id> done` (separate step, see Quirks)

This mirrors what nvim's `zn m` keymap does interactively.

---

## Search for tasks by keyword

```bash
task /KEYWORD/ list          # Search description + annotations in pending tasks
task /KEYWORD/ all           # Include completed/deleted
task project:zksystem /type-prefix/ list   # Scoped to a project
task status:pending and description~=KEYWORD list  # Explicit field search
```

Use `task /KEYWORD/ list` as the default — it searches description + annotations natively, respects TW filters, and is far simpler than piping through Python.

---

## Common Workflows

### "What's on my plate?"
```bash
task summary && echo "---" && task +OVERDUE list
```

### "What's due this week?"
```bash
task due.by:eow list
```

### "Add X to my tasks"
```bash
task add "X"
# Add project:/due:/priority: only if user specifies them
# Avoid dashes in project names
```

### "Mark task 5 as done"
```bash
task 5 done
```

### "Record progress on task 5"
```bash
$HOME/.agents/skills/task/scripts/tw-note.sh 5 --edit "- $(date -I): made progress on X"
```

### "What notes do I have on task 5?"
```bash
$HOME/.agents/skills/task/scripts/tw-note.sh 5
```

---

## Task Creation Interview

When the user asks to **create a task** (add/insert), run this small interview to clarify context before executing. Do NOT ask all questions — pick only the ones whose answers are not already implied by the user's request.

### Interview Questions (pick relevant ones)

| Question | Purpose |
|----------|---------|
| What's the task? | Description (required) |
| What's the purpose or context? | Written into the task note via `--edit` |
| How important is this? | Priority: H / M / L / none |
| What project does this belong to? | Project name (check known list) |
| Is there a deadline? | Due date |
| Any tags, dependencies, or related tasks? | Tags, depends, annotations |

### Rules

1.  **Don't ask what's already known.** If the user says "add a high-priority task to clean up inbox", you already have priority and description — skip those questions.
2.  **Always ask about purpose** — this goes directly into the task note via `tw-note.sh --edit`. If the user's request is brief and ambiguous, ask "what's the purpose or context?" before executing.
3.  **Note creation is non-optional** — every task gets a zk note with the clarified purpose, written via `--edit`. For brief tasks, write a short note anyway (1-2 lines).
4.  After the interview, execute in one batch: `task add ...` + `$HOME/.agents/skills/task/scripts/tw-note.sh <id> --edit "purpose/context"`

### Example Flow

> **User**: add a task to research claude code pricing
> **Agent**: What project? (default: inbox) Any deadline?
> **User**: project:job, no deadline
> **Agent**: *executes `task add "research claude code pricing" project:job` + writes purpose note*
> 
> **User**: add high-priority task to fix login bug
> **Agent**: What project? Any context on what's broken?
> **User**: side-project, the OAuth token refresh is broken
> **Agent**: *executes with priority:H + writes note with context about OAuth token refresh*

### For Modify / Done / Delete

For modify/done/delete operations, skip the interview — just execute. Only interview for **create/add** operations.
