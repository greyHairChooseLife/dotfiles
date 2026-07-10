---
name: zk-triage
description: Triage the zk inbox — sweep raw fleeting notes and finished task-notes, then propose deleting / promoting / filing each into project, area, or resource. Use when the user says "triage inbox", "정리하자", "clean up the zk inbox", or when the weekly inbox-triage task comes due. SKIP for moving a single known note (just mv it), for creating notes (that's a producer skill), and for reflection journaling (that's reflect-event).
---

# zk-triage

Empty the zk inbox by routing each note to its permanent home. This is the
**organizer** in the zk-agent skill family (producer → inbox → **organizer** →
project/area/resource/deleted → archive).

Operate as **propose → approve**: never delete or move a file before the user
approves the batch. The user's trust in this skill is the whole point — one
silent wrong deletion breaks it.

The routing rule below is self-contained. Open the full model
(`~/Documents/zk/inbox/master_20260709-234057.md`) only to settle a genuine
boundary case the rule doesn't cover — e.g. "is this subject an area or a
project", "does this borderline note count as reference or trash".

## The routing rule (this is the whole skill)

Every inbox note resolves to exactly one destination. Decide by asking, in order:

1.  **Is it a live task-note?** (its task is still pending/active in TaskWarrior)
    → **leave in inbox.** Work in progress lives in the waiting room. Do not move.
2.  **Is it raw fleeting with no lasting value?** → **delete.** git is the safety net.
    Do not hoard "아쉬우니까". If unsure whether it has value, treat as reference (step 4).
3.  **Does it carry knowledge tied to a finished task or a subject?** → **graduate:**
    -   the task is `para:proj` (완료조건 O, done) → `project/<name>/`
    -   the task is `para:area`, or it's subject-knowledge not tied to one task → `area/<name>/`
4.  **Is it a reference — useful later, not something to act on?** → `resource/`.
    (reference is a note's *output character*, set via frontmatter `type: reference`;
    it is NOT a task's para value.)
5.  **Should it become actionable but isn't a task yet?** (a fleeting idea worth doing)
    → **propose promoting to a task** (`task add ...`), leave the note in inbox until
    the task exists, then it becomes a live task-note (step 1).

Archive is NOT an inbox destination. Only whole finished projects / retired areas
go to `archive/{project,area}/<name>/`, mirroring the live structure. A note never
lands in archive straight from inbox.

## Reading a note's task state

Task metadata lives in TaskWarrior, not the note. For a task-note (frontmatter
`type: taskwarrior`, has `task-uuid`), resolve state by uuid — **not by numeric id**
(ids get reassigned; see the task skill's Quirks):

```bash
task <uuid> info        # status (pending/completed/deleted), para, project
```

- pending/active → live, step 1.
- completed → graduate by its `para` (step 3).
- deleted → the note is usually deletable too (step 2), unless it holds standalone value.

Notes with no `task-uuid` are pure fleeting → steps 2/4/5.

## Procedure: propose → approve → execute

1.  **Sweep.** List every file in `inbox/`. For each, gather: has task-uuid?
    task status + para? frontmatter type? age?
2.  **Propose.** Present ONE table: each note → proposed destination → one-line reason.
    Group by action (delete / graduate→project / graduate→area / →resource /
    promote-to-task / keep). Call out anything ambiguous explicitly — do not hide a
    guess as a decision.
3.  **Exit criterion — do not execute until the user approves.** The user may edit
    the plan. Deletions especially need an explicit yes. If the user goes silent on
    an item, default to **keep in inbox**, never to delete.
4.  **Execute** the approved batch:
    -   move: use the note rename/move workflow in the task skill (edit frontmatter
        if type changes, move file, update any `zk` UDA that points at it).
    -   delete: `rm` (git holds history).
    -   promote: `task add ...` + link the new task-note.
5.  **Log.** If this run came from the weekly triage task, append a progress line to
    that task's note (`tw-note.sh <uuid> --edit "triaged N notes: ..."`) — the log
    becomes training data for later automation.

## What this skill does NOT do

- It does not create knowledge notes (producers do that).
- It does not move a single note the user already named — that's a one-off `mv`.
- It does not touch `resource/` reflection journals or reflect-event output.
- It does not retroactively reorganize `project/`, `area/`, or `archive/` — only
  routes OUT of inbox. Restructuring live dirs is a separate task.
