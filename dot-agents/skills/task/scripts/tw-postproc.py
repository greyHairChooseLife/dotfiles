#!/usr/bin/env python3
"""Task note post-processor for tw-note.sh.

Usage:
    tw-postproc.py init <note_path> <uuid> <context_text>
        Replace the body of a newly created note with the task note structure.
        The context_text becomes the ## Context section.

    tw-postproc.py progress <note_path> <progress_text>
        Append a timestamped entry under ## Progress.
"""

import sys
import re
from datetime import datetime


def die(msg: str) -> None:
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


def init_note(note_path: str, uuid: str, context_text: str) -> None:
    date_str = datetime.now().strftime("%Y-%m-%d")

    with open(note_path) as f:
        content = f.read()

    fm_end = content.find("---", 3)
    if fm_end == -1:
        die(f"no frontmatter found in {note_path}")

    fm = content[:fm_end + 4]

    title_match = re.search(r'title:\s*"?(.+?)"?\s*$', fm, re.MULTILINE)
    title = title_match.group(1).strip('"') if title_match else "untitled"

    new_fm = f'---\ntitle: "{title}"\ntype: taskwarrior\ntask-uuid: {uuid}\n---\n'
    new_body = (
        f"# {title}\n\n"
        f"## Context\n\n"
        f"{context_text}\n\n"
        f"## Progress\n\n"
        f"- {date_str}: Created\n\n"
        f"## Reference\n"
    )

    with open(note_path, "w") as f:
        f.write(new_fm + "\n" + new_body)

    print(note_path)


def append_progress(note_path: str, progress_text: str) -> None:
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")
    entry = f"- {timestamp}: {progress_text}"

    with open(note_path) as f:
        content = f.read()

    if "## Progress" in content:
        new_content = content.replace("## Progress\n", f"## Progress\n\n{entry}\n", 1)
    else:
        new_content = content.rstrip() + f"\n\n## Progress\n\n{entry}\n"

    with open(note_path, "w") as f:
        f.write(new_content)

    print(note_path)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        die(f"Usage: {sys.argv[0]} <init|progress> <note_path> [args...]")

    cmd = sys.argv[1]
    note_path = sys.argv[2]

    if cmd == "init":
        if len(sys.argv) != 5:
            die("Usage: tw-postproc.py init <note_path> <uuid> <context_text>")
        init_note(note_path, sys.argv[3], sys.argv[4])
    elif cmd == "progress":
        if len(sys.argv) != 4:
            die("Usage: tw-postproc.py progress <note_path> <progress_text>")
        append_progress(note_path, sys.argv[3])
    else:
        die(f"Unknown command: {cmd}")
