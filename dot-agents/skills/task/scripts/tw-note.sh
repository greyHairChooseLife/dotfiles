#!/usr/bin/env bash
# tw-note.sh — Read or edit a task's linked zettelkasten note
# Usage:
#   tw-note.sh <uuid|id>               Read the note
#   tw-note.sh <uuid|id> --edit "..."   Append progress to an EXISTING note
#   tw-note.sh <uuid|id> --create "..."  Create a NEW note with initial context
#
# Prefer <uuid> over numeric <id>: task IDs are reassigned by TaskWarrior when
# tasks complete/delete, so a stale id can point at the wrong task. --edit and
# --create refuse to guess: --edit errors if no note exists, --create errors if
# one already does, so a mis-resolved id fails loudly instead of silently
# creating a note on / overwriting the wrong task.
#
# Task notes are created in inbox/ via zn-api, then post-processed by tw-postproc.py
# into the task note structure (## Context, ## Progress, ## Reference).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POSTPROC="$SCRIPT_DIR/tw-postproc.py"

die() { echo "ERROR: $*" >&2; exit 1; }

TARGET="$1"
shift 2>/dev/null || true
EDIT_MODE=false
CREATE_MODE=false
EDIT_TEXT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --edit)
            EDIT_MODE=true
            EDIT_TEXT="$2"
            shift 2
            ;;
        --create)
            CREATE_MODE=true
            EDIT_TEXT="$2"
            shift 2
            ;;
        *) die "Unknown option: $1" ;;
    esac
done

if $EDIT_MODE && $CREATE_MODE; then
    die "--edit and --create are mutually exclusive"
fi

# --- Resolve to UUID if given a numeric ID ---
if [[ "$TARGET" =~ ^[0-9]+$ ]]; then
    UUID=$(task "$TARGET" _uuid 2>/dev/null || echo "")
    if [[ -z "$UUID" ]]; then
        die "Task $TARGET not found"
    fi
else
    UUID="$TARGET"
fi

# --- Get task data ---
TASK_JSON=$(task "$UUID" export 2>/dev/null || echo "[]")
if [[ "$TASK_JSON" == "[]" ]]; then
    die "Task $UUID not found"
fi

ZK_PATH=$(echo "$TASK_JSON" | python3 -c "
import sys, json, os
tasks = json.load(sys.stdin)
if not tasks:
    sys.exit(1)
t = tasks[0]
zk = t.get('zk', '')
if not zk:
    sys.exit(2)
print(os.path.expanduser(zk))
") || {
    EXIT=$?
    if [[ $EXIT -eq 2 ]]; then
        die "No zk note path linked to this task"
    else
        die "Failed to parse task data"
    fi
}

DESCRIPTION=$(echo "$TASK_JSON" | python3 -c "
import sys, json
tasks = json.load(sys.stdin)
print(tasks[0].get('description', 'untitled'))
")

# --- Note already exists ---
if [[ -f "$ZK_PATH" ]]; then
    if $CREATE_MODE; then
        die "Note already exists for this task ($DESCRIPTION): $ZK_PATH
Use --edit to append progress. If you meant a different task, pass its uuid, not a numeric id."
    elif $EDIT_MODE; then
        python3 "$POSTPROC" progress "$ZK_PATH" "$EDIT_TEXT"
        echo "Progress appended to: $ZK_PATH"
    else
        cat "$ZK_PATH"
    fi
    exit 0
fi

# --- Note doesn't exist yet ---
if $EDIT_MODE; then
    die "No note exists yet for this task ($DESCRIPTION).
Use --create to create it. If you expected a note here, the id may be stale — pass the uuid instead."
fi
if ! $CREATE_MODE; then
    echo "Note not created yet."
    echo "Use --create to create the note and add initial context."
    exit 0
fi

# --- Create new note via zn-api in inbox ---
NOTE_PATH=$(zsh -i -c "zn-api taskwarrior taskwarrior inbox $(printf '%q' "$DESCRIPTION")" 2>/dev/null)

if [[ -z "$NOTE_PATH" || ! -f "$NOTE_PATH" ]]; then
    die "Failed to create note via zn-api"
fi

# --- Apply task note structure ---
python3 "$POSTPROC" init "$NOTE_PATH" "$UUID" "$EDIT_TEXT"

# --- Update task's zk UDA to point to the created file ---
task "$UUID" modify "zk:$NOTE_PATH" >/dev/null 2>&1 || true

echo "Created note: $NOTE_PATH"
