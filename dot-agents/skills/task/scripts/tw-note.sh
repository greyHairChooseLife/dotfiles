#!/usr/bin/env bash
# tw-note.sh — Read, create, or annotate a task's linked zettelkasten note
# Usage:
#   tw-note.sh <uuid|id>               Read the note
#   tw-note.sh <uuid|id> --create "..."  Create a NEW note with context text
#   tw-note.sh <uuid|id> --annotate "..."  Add TW annotation (replaces old --edit)
#
# Prefer <uuid> over numeric <id>: task IDs are reassigned by TaskWarrior when
# tasks complete/delete, so a stale id can point at the wrong task. --create
# refuses to overwrite: it errors if a note already exists, so a mis-resolved
# id fails loudly instead of silently creating a note on the wrong task.
#
# Task notes are created in inbox/ via zk new --template taskwarrior.md.
# Structure: frontmatter (title, type, task-uuid, created, updated) +
# ## Context / ## Done when.

set -euo pipefail

die() { echo "ERROR: $*" >&2; exit 1; }

TARGET="$1"
shift 2>/dev/null || true
CREATE_MODE=false
ANNOTATE_MODE=false
TEXT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --create)
            CREATE_MODE=true
            TEXT="$2"
            shift 2
            ;;
        --annotate)
            ANNOTATE_MODE=true
            TEXT="$2"
            shift 2
            ;;
        --edit)
            die "--edit is deprecated. Use --annotate to record progress as a TW annotation."
            ;;
        *) die "Unknown option: $1" ;;
    esac
done

if $CREATE_MODE && $ANNOTATE_MODE; then
    die "--create and --annotate are mutually exclusive"
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

# --- Annotate mode (replaces old --edit) ---
if $ANNOTATE_MODE; then
    task "$UUID" annotate "$TEXT"
    echo "Annotated task $UUID"
    exit 0
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
        ZK_PATH=""
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
if [[ -n "${ZK_PATH:-}" && -f "$ZK_PATH" ]]; then
    if $CREATE_MODE; then
        die "Note already exists for this task ($DESCRIPTION): $ZK_PATH
If you meant a different task, pass its uuid, not a numeric id."
    else
        cat "$ZK_PATH"
    fi
    exit 0
fi

# --- Note doesn't exist yet ---
if ! $CREATE_MODE; then
    echo "Note not created yet."
    echo "Use --create to create the note and add initial context."
    exit 0
fi

# --- Create new note via zk CLI ---
NOTEBOOK_DIR="$HOME/Documents/zk"
NOTE_PATH=$(echo "$TEXT" | zk new -i --working-dir "$NOTEBOOK_DIR" inbox \
    --template taskwarrior.md \
    --title "$DESCRIPTION" \
    --extra=uuid="$UUID" \
    --extra=type=taskwarrior \
    --print-path 2>/dev/null)

if [[ -z "$NOTE_PATH" || ! -f "$NOTE_PATH" ]]; then
    die "Failed to create note via zk new"
fi

# --- Create resource directory ---
RES_DIR="$NOTEBOOK_DIR/resource/task-static/$UUID"
mkdir -p "$RES_DIR"

# --- Update task UDAs ---
task "$UUID" modify "zk:$NOTE_PATH" "resources:$RES_DIR" >/dev/null 2>&1 || true

echo "Created note: $NOTE_PATH"
