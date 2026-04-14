#!/usr/bin/env python3
"""Export user messages from Claude Code history to an English study note."""

import json
import sys
from pathlib import Path

HISTORY = Path.home() / ".claude" / "history.jsonl"
OUTPUT = Path.home() / "english-study-notes.md"


def load_checkpoint(output: Path) -> int:
    """Return the latest timestamp from the source file, or 0 if none."""
    if not output.exists():
        return 0
    last_ts = 0
    with open(output) as f:
        for line in f:
            if line.startswith("<!-- ts:"):
                ts = line.strip().removeprefix("<!-- ts:").removesuffix(" -->")
                try:
                    last_ts = max(last_ts, int(ts))
                except ValueError:
                    pass
    return last_ts


def is_english(text: str) -> bool:
    printable = [c for c in text if not c.isspace()]
    if not printable:
        return False
    ascii_ratio = sum(1 for c in printable if ord(c) < 128) / len(printable)
    return ascii_ratio >= 0.9


def main():
    if not HISTORY.exists():
        print(f"History file not found: {HISTORY}", file=sys.stderr)
        sys.exit(1)

    checkpoint = load_checkpoint(OUTPUT)

    new_entries = []
    with open(HISTORY) as f:
        for line in f:
            d = json.loads(line)
            ts = d.get("timestamp", 0)
            text = d.get("display", "").strip()
            if not text or ts <= checkpoint or not is_english(text):
                continue
            new_entries.append((ts, text))

    if not new_entries:
        print("No new messages.")
        return

    with open(OUTPUT, "a") as f:
        for ts, text in new_entries:
            f.write(f"<!-- ts:{ts} -->\n")
            f.write(f"{text.rstrip()}\n")

    print(f"Appended {len(new_entries)} new messages to {OUTPUT}")


if __name__ == "__main__":
    main()
