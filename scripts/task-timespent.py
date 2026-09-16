#!/usr/bin/env python3
"""Day-by-day timespent breakdown for a TaskWarrior task.

Parses the modification log from `task <id> info`, reconstructs each
start/stop session, applies the manual AFK corrections, splits overnight
sessions at midnight, and prints a markdown table (whole hours).

Usage: task-timespent.py <task-id>
"""

import collections
import datetime
import re
import subprocess
import sys

DM = r"Timespent (?:set to|changed from '[\d:]+' to) '(\d+:\d+:\d+)'"


def parse_log(text):
    """Parse the Date/Modification section into ordered events."""
    lines = text.splitlines()
    try:
        start = next(i for i, l in enumerate(lines) if l.startswith("Date"))
    except StopIteration:
        return []
    events = []
    date = time = None
    buf = []

    def flush():
        if date and time is not None:
            events.append({
                "dt": datetime.datetime.strptime(f"{date} {time}", "%Y-%m-%d %H:%M:%S"),
                "text": " ".join(x for x in buf if x),
            })

    for l in lines[start + 2:]:
        m = re.match(r"^(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2})\s*(.*)", l)
        if m:
            flush(); date, time, buf = m.group(1), m.group(2), [m.group(3)]; continue
        m = re.match(r"^(\d{4}-\d{2}-\d{2})\s+(.*)", l)
        if m:
            flush(); date, time, buf = m.group(1), None, [m.group(2)]; continue
        m = re.match(r"^(\d{2}:\d{2}:\d{2})\s*(.*)", l)
        if m:
            flush(); time, buf = m.group(1), [m.group(2)]; continue
        if l.strip():
            buf.append(l.strip())
    flush()
    return events


def ts(s):
    h, m, sec = map(int, s.split(":"))
    return h * 3600 + m * 60 + sec


def analyze(events):
    """Return list of sessions (start_dt, stop_dt, effective_seconds)."""
    sessions = []
    pending = None
    pending_val = 0
    last = 0
    for e in events:
        t = e["text"]
        dm = re.search(DM, t)
        if "Start deleted (duration" in t:
            stop = e["dt"]
            # value at stop, then any corrections within 3 minutes
            if pending:
                eff = ts(dm.group(1)) if dm else last
                j = events.index(e) + 1
                while j < len(events) and (events[j]["dt"] - stop).total_seconds() <= 180:
                    cm = re.search(DM, events[j]["text"])
                    if cm:
                        eff = ts(cm.group(1))
                    j += 1
                sessions.append((pending, stop, eff - pending_val))
            if dm:
                last = ts(dm.group(1))
            pending = None
            continue
        sm = re.search(r"Start set to '([\d\- :]+?)\.?'", t)
        if sm and pending is None:
            pending = datetime.datetime.strptime(sm.group(1).strip(), "%Y-%m-%d %H:%M:%S")
            pending_val = last
        if dm:
            last = ts(dm.group(1))
    return sessions


def split_days(sdt, edt, sec):
    """Split a session's seconds across calendar dates at midnight."""
    span = (edt - sdt).total_seconds()
    out = collections.defaultdict(float)
    cur = sdt
    while cur < edt:
        nxt = min((cur + datetime.timedelta(days=1)).replace(hour=0), edt)
        out[cur.date()] += sec * (nxt - cur).total_seconds() / span
        cur = nxt
    return out


def main():
    if len(sys.argv) != 2:
        sys.exit(f"usage: {sys.argv[0]} <task-id>")
    tid = sys.argv[1]
    info = subprocess.run(
        ["task", "rc.color=off", tid, "info"],
        capture_output=True, text=True, check=True,
    ).stdout
    events = parse_log(info)
    if not events:
        sys.exit("no modification log found")

    sessions = analyze(events)
    daily = collections.defaultdict(float)
    for sdt, edt, sec in sessions:
        if sec <= 0:
            continue
        for d, v in split_days(sdt, edt, sec).items():
            daily[d] += v

    desc = subprocess.run(
        ["task", "rc.color=off", tid, "description"],
        capture_output=True, text=True, check=True,
    ).stdout.strip().splitlines()
    print(f"# Timespent — task {tid}: {desc[0] if desc else ''}\n")
    print("| Date       | Time |")
    print("|------------|------|")
    total = 0.0
    for d in sorted(daily):
        if daily[d] < 60:
            continue
        total += daily[d]
        print(f"| {d} | {int(daily[d]) // 3600}h |")
    print(f"| **Total**  | **{int(total) // 3600}h** |")


if __name__ == "__main__":
    main()
