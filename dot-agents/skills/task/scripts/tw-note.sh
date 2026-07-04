#!/usr/bin/env bash
# tw-note.sh — Read or edit a task's linked zettelkasten note
# Usage:
#   ./tw-note.sh <uuid|id>              Read the note
#   ./tw-note.sh <uuid|id> --edit "..."  Append text to the note
#
# Creates the note via zn-api (nvim ZnAPI) if it does not exist yet.

set -euo pipefail

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
        *)
            die "Unknown option: $1"
            ;;
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

# --- If it's already a file, just read/append ---
if [[ -f "$ZK_PATH" ]]; then
    if $EDIT_MODE; then
        echo "$EDIT_TEXT" >> "$ZK_PATH"
        echo "Appended to: $ZK_PATH"
    else
        cat "$ZK_PATH"
    fi
    exit 0
fi

# --- Note doesn't exist yet ---
if ! $EDIT_MODE; then
    if [[ -d "$ZK_PATH" ]]; then
        echo "Note not created yet. Directory exists: $ZK_PATH"
    else
        echo "Note not created yet. Path: $ZK_PATH"
    fi
    echo "Use --edit to create the note and add content."
    exit 0
fi

# --- Create directory if needed ---
mkdir -p "$ZK_PATH"

# --- Create note via zn-api (same method as the user's open-zk-note-with-nvim.sh) ---
ZK_NB="${ZK_NOTEBOOK_DIR:-$HOME/Documents/zk}"
ZK_RELPATH=$(python3 -c "import os; print(os.path.relpath('$ZK_PATH', '$ZK_NB'))")

NOTE_PATH=$(zsh -i -c "zn-api taskwarrior fleeting $(printf '%q' "$ZK_RELPATH") $(printf '%q' "$DESCRIPTION")" 2>/dev/null)

if [[ -z "$NOTE_PATH" || ! -f "$NOTE_PATH" ]]; then
    die "Failed to create note via zn-api"
fi

# Add task-uuid to frontmatter
python3 -c "
import re
path = '$NOTE_PATH'
uuid = '$UUID'
text = open(path).read()
if 'task-uuid:' not in text:
    new = re.sub(r'(---\n[\s\S]*?)(---)', r'\1task-uuid: ' + uuid + r'\n\2', text, count=1)
    open(path, 'w').write(new)
"

# Update task's zk UDA to point to the file
task "$UUID" modify "zk:$NOTE_PATH" >/dev/null 2>&1 || true

# Append edit text if provided
if [[ -n "$EDIT_TEXT" ]]; then
    echo "$EDIT_TEXT" >> "$NOTE_PATH"
fi

echo "Created note: $NOTE_PATH"
