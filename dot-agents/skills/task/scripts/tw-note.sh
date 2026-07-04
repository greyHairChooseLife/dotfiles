#!/usr/bin/env bash
# tw-note.sh — Read or edit a task's linked zettelkasten note
# Usage:
#   tw-note.sh <uuid|id>              Read the note
#   tw-note.sh <uuid|id> --edit "..."  Create with context (new) or append progress (existing)
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
EDIT_TEXT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --edit)
            EDIT_MODE=true
            EDIT_TEXT="$2"
            shift 2
            ;;
        *) die "Unknown option: $1" ;;
    esac
done

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

# --- If note already exists, read or append progress ---
if [[ -f "$ZK_PATH" ]]; then
    if $EDIT_MODE; then
        python3 "$POSTPROC" progress "$ZK_PATH" "$EDIT_TEXT"
        echo "Progress appended to: $ZK_PATH"
    else
        cat "$ZK_PATH"
    fi
    exit 0
fi

# --- Note doesn't exist yet ---
if ! $EDIT_MODE; then
    echo "Note not created yet."
    echo "Use --edit to create the note and add initial context."
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
