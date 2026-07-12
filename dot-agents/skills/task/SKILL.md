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
  - `zk` — path to the linked note (`~/Documents/zk/inbox/taskwarrior_*.md`).
  - `resources` — attached-files dir (`~/Documents/zk/resource/task-static/<uuid>/`).
  - `timespent` — accumulated `HH:MM:SS`, auto-tracked.
  - `para` — 3-state: `proj` (완료조건 O, finishes) / `area` (지속, ongoing) / **empty** (유보 — proj/area 아직 미정). A *hint* zk-triage reads when a finished task's note graduates; not a classification axis. Mutable — may flip proj↔area or be cleared as the task evolves. `proj` not `project` — TW reserves `project`.
- **Projects** — free-form; unknown ones are created on use; default `inbox`.
  TW `project` is a broad bucket ≈ PARA area. The `para` UDA is NOT a classification
  axis — it's only a graduation hint for the note (see UDAs above).

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

Every task has a linked note in `~/Documents/zk/inbox/`, created via `zk new
--template taskwarrior.md`. Structure: frontmatter (`title`, `type: taskwarrior`,
`task-uuid`, `created`, `updated`) + `## Context` / `## Done when`.
**All task metadata lives in TaskWarrior**, not the note — query it via `task <id> info`.

### Progress logging

Short progress entries go to TW annotations (`task <id> annotate`), NOT the note.
The `## Context` section accumulates long-form context/decisions/insights only.
When using `--annotate`, reference the note if details live there:
`task <id> annotate "phase1 done, detail in note ## Context"`.

### Attached files

Place files in `~/Documents/zk/resource/task-static/<uuid>/`.
Reference from Context with wiki links: `![[../resource/task-static/<uuid>/file]]`.

### Helper script

```bash
SCRIPTS=/home/sy/.agents/skills/task/scripts
$SCRIPTS/tw-note.sh <uuid|id>                    # Read the note
$SCRIPTS/tw-note.sh <uuid|id> --create "text"     # Create a NEW note, text → ## Context
$SCRIPTS/tw-note.sh <uuid|id> --annotate "text"   # Add a TW annotation (progress)
```

`--create` errors if a note exists (no overwrite), so a stale id fails loudly.
**Prefer uuid over id** (see Quirks).

- New task → `--create` (right after `task add`).
- "record progress on task Y" → `--annotate` (TW annotation, not the note).

### Rename/move a note

Don't `mv` directly. Edit frontmatter → rename file → `task <id> modify zk:<new-abs-path>`.
Note graduation (taskwarrior→reference etc.) is handled by `zk-triage`, not `task` skill.

## Search

`task /KEYWORD/ list` is the default — searches description + annotations, respects
TW filters. Add `all` to include completed/deleted; scope with `project:X`.

## Creating a task (interview)

When the user asks to add a task, infer what you can, ask only what's missing.
5 things to capture — some inferrable, some not:

| Item | Destination | Infer? |
|------|------------|--------|
| **what** (description) | TW `description` | from user's request |
| **why** (context) | note `## Context` | usually inferrable, 1-2 lines |
| **when** (due/schedule) | TW `due` | ask if ambiguous, else skip |
| **reference** (links/files) | note `## Context` | ask if implied, else skip |
| **완료조건** (completion criteria) | note `## Done when` checkbox | always ask — minimum 1 |

- **Context** — near-universal. Even a brief task gets 1-2 lines. Skip only if the
  description already spells out the goal.
- **Project/priority by nature:** learning/reading → `study` M · coding/bug/feature
  → `side-project` M · work → `job` M · chore/admin → `inbox` L · zk/system → `zksystem` M.
- **`para` — always ask, never auto-set.** Present all three: `proj` / `area` / **empty** (유보).
  Offer a recommendation but let the user decide.
- Execute in one batch: `task add ...` + `tw-note.sh <id> --create "context"`.

For modify/done/delete: skip the interview, just execute.
