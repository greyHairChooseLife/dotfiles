---
name: task
description: Task management via TaskWarrior CLI. Use when the user asks to view, add, complete, or modify tasks. Handles project filtering, due dates, priorities, tags, and task-linked zettelkasten notes. Integrates with taskwarrior-tui + hooks + zk note system.
---

# Task

## System Overview

- **TaskWarrior CLI** (`task`) — core task management
- **taskwarrior-tui** — terminal UI (interactive, human-only — you never open it)
- **Hooks** — auto-run on add/modify (documented below, you don't invoke them)
- **Zettelkasten** — each task gets a linked markdown note in `~/Documents/zk/inbox/` with a structured task format (Context, Progress, Reference)

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

Every task has a linked zk note in `~/Documents/zk/inbox/`. Notes follow a structured format maintained by the agent's `tw-note.sh` script — not by zk templates.

### Note Structure

```markdown
---
title: "task description"
type: taskwarrior
task-uuid: <uuid>
---

# title

## Context
<!-- Task 생성 이유, 목적, 기대 결과 -->

## Progress
<!-- timestamped 작업 로그 -->

## Reference
<!-- 관련 링크, 문서, 참고자료 -->
```

**Metadata lives in TaskWarrior** — only `title`, `type`, and `task-uuid` are in frontmatter. All task metadata (status, priority, due, project, tags, time tracking) is queried from TW via `task <id> info`.

### Helper Script

```bash
/home/sy/.agents/skills/task/scripts/tw-note.sh <uuid-or-id>                # Read the note
/home/sy/.agents/skills/task/scripts/tw-note.sh <uuid-or-id> --edit "text"   # Create with context (first use) or append progress (subsequent)
```

`--edit` behavior by note state:

| State | `--edit` does |
|-------|--------------|
| No note exists | Creates note in `inbox/` via zn-api, populates `## Context` with the text, adds "Created" entry under `## Progress` |
| Note exists | Appends timestamped entry (`- YYYY-MM-DD HH:MM: text`) under `## Progress` |

When the user says "record X about task Y" or "write a note for task Y", use `--edit`. The timestamp prefix is added automatically — do not include it in the text.

### Note rename/move workflow

When you need to rename a task note (change type prefix, title, or move it), do NOT use `mv` directly. Manual steps:

1.  Edit frontmatter: change `type`, `title` as needed
2.  Rename the file: update the type prefix in filename (e.g., `taskwarrior_` → `reference_`)
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
/home/sy/.agents/skills/task/scripts/tw-note.sh 5 --edit "made progress on X"
```
The timestamp is added automatically. Do not include it in the text.

### "What notes do I have on task 5?"
```bash
/home/sy/.agents/skills/task/scripts/tw-note.sh 5
```

---

## Task Creation Interview

When the user asks to **create a task** (add/insert), run this small interview to clarify context before executing. Do NOT ask all questions — pick only the ones whose answers are not already implied by the user's request.

### How It Works

Agent picks **1–2 most relevant fields** missing from the user's request and presents them as a one-shot prompt. The user replies with `key=value` pairs in a single line. Fields already specified by the user are never re-asked.

### Field Reference

| Key | Field | Format | When to ask |
|-----|-------|--------|------------|
| b | Project | `1=inbox, 2=job, 3=side-project, 4=study, 5=business, 6=note-taking, 7=zksystem, 8=미래지식융합학회, 9=<name>` | Suggest based on task nature (see table below) |
| c | Context | free text | Almost always — becomes `## Context`. Skip only if description fully explains the goal |
| d | Due | `1=today, 2=tomorrow, 3=eow, 4=none, 5=YYYY-MM-DD` | Only when the task sounds deadline-sensitive |
| a | Priority | `1=H, 2=M, 3=L, 4=none` | Only when urgency is unclear or user explicitly wants to set it |
| e | Tags | comma-separated | Rare — when user mentions categories or labels naturally |

### Suggested Defaults

| Task nature | Project | Priority |
|-------------|---------|----------|
| research, reading, learning | study | M |
| bug fix, feature, coding | side-project | M |
| work, job-related | job | M |
| chore, quick note, admin | inbox | L |
| zk/wiki/system work | zksystem | M |

### Rules

1.  **Never re-ask what the user already said.** If they said "high-priority bug fix", don't ask about priority.
2.  **Pick at most 2 fields.** Typically just `c` (context). Occasionally `b` + `c` when project isn't obvious.
3.  **Suggest a default** based on task nature. User accepts by typing just the letter (`c`) or reply with the key=value shorthand.
4.  **Context (`c`) is the only near-universal field.** Ask it unless the description already spells out the complete goal. Even a brief task gets a short context (1–2 lines).
5.  After user replies (or confirms defaults), execute in one batch: `task add ...` + `tw-note.sh <id> --edit "context text"`.

### Example Flows

> **User**: add a task to research claude code pricing
> **Agent**: b=study? c: <purpose>?
> **User**: b2, c: compare Codex vs GPT-4.1 pricing for the task skill
> **Agent**: *executes `task add "research claude code pricing" project:job` + writes note with Context*

> **User**: add high-priority task to fix login bug
> **Agent**: OAuth broken? project: side-project, c: <context>?
> **User**: side-project, c: OAuth token refresh returns 401 after 1h
> **Agent**: *executes with priority:H + project:side-project + writes note*

> **User**: task: clean up inbox
> **Agent**: c: <what exactly to clean up>?
> **User**: c: archive completed tasks older than 2 weeks
> **Agent**: *executes + writes note*

> **User**: add task to review PR #42 by end of week
> **Agent**: c: <context>? d=eow?
> **User**: y

### For Modify / Done / Delete

For modify/done/delete operations, skip the interview — just execute. Only interview for **create/add** operations.
