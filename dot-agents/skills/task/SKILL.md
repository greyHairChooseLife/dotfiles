---
name: task
description: Task management via TaskWarrior CLI. Use when the user asks to view, add, complete, or modify tasks, or to record progress on a task's linked note. Handles project filtering, due dates, priorities, tags, PARA classification, and task-linked zettelkasten notes. SKIP for plain calendar reminders, code TODOs, or the zk inbox triage (that's zk-triage).
---

# Task

TaskWarrior (`task`) with a linked zettelkasten note per task. You drive the CLI;
`taskwarrior-tui` is the human's interactive view — never open it. Standard TW
commands (`task next`, `task add`, `task <id> modify/done/delete`, filters like
`+OVERDUE`, `due.by:eow`, `project:X`) work as documented upstream — this file
only covers what is specific to THIS environment or easy to get wrong.

## System

- **Hooks** (auto-run, you never invoke them):
  - `on-add`: sets `zk` + `resources` UDAs; defaults `project` to `inbox`. Recurring tasks copy from parent.
  - `on-modify`: accumulates `timespent` on start/stop; on done/delete tags the zk note `taskwarrior-completed`/`taskwarrior-deleted`.
- **Custom UDAs:**
  - `zk` — path to the linked note (a directory until first opened, then the `.md` file).
  - `resources` — attached-files dir (`~/.tasks-resources/<uuid>/`).
  - `timespent` — accumulated `HH:MM:SS`, auto-tracked.
  - `para` — `proj` (완료조건 O, finishes) or `area` (지속, ongoing). Sets a note's graduation home on completion; used by zk-triage. `proj` not `project` — TW reserves `project`.
- **Projects** (free-form; unknown ones are created on use; default `inbox`):
  `business, inbox, job, note-taking, side-project, study, zksystem, 미래지식융합학회`
  Note: TW `project` is a broad bucket ≈ PARA area; the `para` UDA is the real project/area axis.

## Quirks (these bite)

| Quirk | Rule |
|-------|------|
| Dashes in project names → TW parses `project:zk-system` as `-system` | Avoid dashes, use underscore. |
| `done` consumed as description (`modify desc:"X" done` → desc="done") | Separate: modify first, then `task <id> done`. |
| `delete`/`stop` block on stdin | Always `rc.confirmation=no`. |
| Can't modify while active | `task <id> stop` first, then modify. |
| `para:project` rejected | Value is `proj`, not `project` (TW reserved word). |
| **IDs are reassigned** — yesterday's `51` may be another task today (TW renumbers on done/delete) | Only uuid is stable. Across a session boundary or after any done/delete, re-resolve (`task <id> info`) or use uuid. Matters for annotate, `done`, and note edits landing on the WRONG task. |

## Task notes (zk)

Every task has a linked note in `~/Documents/zk/inbox/`, maintained by `tw-note.sh`
(not zk templates). Structure: frontmatter (`title`, `type: taskwarrior`,
`task-uuid` only) + `## Context` / `## Progress` / `## Reference`.
**All task metadata lives in TaskWarrior**, not the note — query it via `task <id> info`.

### Helper script

```bash
SCRIPTS=/home/sy/.agents/skills/task/scripts
$SCRIPTS/tw-note.sh <uuid|id>                 # Read the note
$SCRIPTS/tw-note.sh <uuid|id> --create "text"  # Create a NEW note, text → ## Context
$SCRIPTS/tw-note.sh <uuid|id> --edit "text"    # Append a progress entry to an EXISTING note
```

`--create` and `--edit` are separate on purpose: `--create` errors if a note
exists (no overwrite), `--edit` errors if none exists (no accidental create). So a
stale id fails loudly instead of writing to the wrong task. **Prefer uuid over id**
(see Quirks). Timestamp prefix is added automatically — don't include it.

- New task → `--create` (right after `task add`).
- "record/note progress on task Y" → `--edit`.

### Rename/move a note

Don't `mv` directly. Edit frontmatter (`type`/`title`) → rename file (update type
prefix, e.g. `taskwarrior_`→`reference_`) → `task <id> modify zk:<new-abs-path>` →
optionally `task <id> done` (separate). Mirrors nvim's `zn m`.

## Search

`task /KEYWORD/ list` is the default — searches description + annotations, respects
TW filters. Add `all` to include completed/deleted; scope with `project:X`.

## Creating a task (interview)

When the user asks to add a task, don't interrogate — infer what you can, ask only
what's missing.

- **Exit criterion:** if a 1-line context is derivable AND the project is inferable
  from the task's nature, execute immediately. Otherwise ask at most 2 fields
  (usually just context) via `AskUserQuestion`, then execute.
- **Context is near-universal** — even a brief task gets a 1–2 line `## Context`.
  Skip only if the description already spells out the goal.
- **Project/priority by nature:** learning/reading → `study` M · coding/bug/feature
  → `side-project` M · work → `job` M · chore/admin → `inbox` L · zk/system → `zksystem` M.
  Set `para:proj` (finishes) or `para:area` (ongoing).
- Execute in one batch: `task add ...` + `tw-note.sh <id> --create "context"`.

For modify/done/delete: skip the interview, just execute.
