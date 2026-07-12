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
3.  **Does it carry knowledge tied to a finished task or a subject?** → **graduate.**
    Use `para` as a *hint* to propose the destination — you consume it, never set it:
    -   `para:proj` → propose `project/<name>/`
    -   `para:area`, or subject-knowledge not tied to one task → propose `area/<name>/`
    -   `para` **empty** (유보) → it's just unset, not an error. Propose by the note's
        own content: has a finish/deliverable → project, ongoing subject → area.
    Every case still goes through propose→approve — para only shapes the suggestion.
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
- completed → graduate (step 3). `para` hints the destination; if empty, propose by
  content. Either way the user confirms — triage reads `para`, never writes it.
- deleted → the note is usually deletable too (step 2), unless it holds standalone value.

Notes with no `task-uuid` are pure fleeting → steps 2/4/5.

## UDA sync: keep `zk` pointing at reality

Every task-note has a `zk` UDA on its TaskWarrior task storing the note's
absolute path. After triage changes the note's location (or deletes it), the
`zk` UDA on the linked task **must** be updated to match — otherwise `tw-note.sh
<uuid>` and the `on-modify` hook break, pointing at a stale or missing file.

| Triage outcome | UDA action |
|----------------|------------|
| Graduate (move to project/area/resource) | `task <uuid> modify zk:<new-abs-path>` |
| Delete note (task still exists) | `task <uuid> modify zk:` (clear the UDA) |
| Delete note (task already deleted) | Nothing — task is gone, UDA is gone |
| Promote to task | `on-add` hook auto-sets `zk`; ensure note path matches (see execute step) |
| Keep in inbox | No change needed |

Always use **uuid** (never numeric id) for modify — ids are reassigned.

## Procedure: propose → approve → execute

1.  **Sweep.** List every file in `inbox/`. For each, gather: has task-uuid?
    task status + para? frontmatter type? age?
2.  **Propose.** Present ONE table: each note → proposed destination → one-line reason
    → **UDA action** (update path / clear / none). Group by action (delete /
    graduate→project / graduate→area / →resource / promote-to-task / keep). Call out
    anything ambiguous explicitly — do not hide a guess as a decision.
3.  **Exit criterion — do not execute until the user approves.** The user may edit
    the plan. Deletions especially need an explicit yes. If the user goes silent on
    an item, default to **keep in inbox**, never to delete.
4.  **Execute** the approved batch (UDA sync is mandatory for every item, not just moves):
    -   **graduate (move):** edit frontmatter if type changes → `mv` file to
        destination → `task <uuid> modify zk:<new-abs-path>`. Use the task skill's
        rename/move workflow. UDA must point at the new path.
    -   **delete:** `rm` (git holds history). If the note had a `task-uuid` and the
        task still exists, clear the UDA: `task <uuid> modify zk:`. If the task is
        already deleted, nothing to do.
    -   **promote:** `task add ...` (hook auto-creates `zk` pointing at
        `~/Documents/zk/inbox/<id>.md`) → move the existing fleeting note's content
        into the new task-note (or update `zk` to point at the existing note and
        delete the empty template). Edit frontmatter: set `type: taskwarrior`,
        add `task-uuid`. Leave in inbox — it is now a live task-note (step 1).
5.  **Log.** If this run came from the weekly triage task, append a progress line to
    that task's note (`tw-note.sh <uuid> --edit "triaged N notes: ..."`) — the log
    becomes training data for later automation.

## What this skill does NOT do

- It does not create knowledge notes (producers do that).
- It does not move a single note the user already named — that's a one-off `mv`.
- It does not touch `resource/` reflection journals or reflect-event output.
- It does not retroactively reorganize `project/`, `area/`, or `archive/` — only
  routes OUT of inbox. Restructuring live dirs is a separate task.
- It does not set or change a task's `para` — para is owned by the task skill. Triage
  only reads it as a routing hint. To fix a wrong para, use the task skill.
