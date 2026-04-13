#!/usr/bin/env python3
"""
i3status output patcher.
Injects a CPU governor block showing current scaling_governor of cpu0.
Format:  pow /  perf /  <governor>
"""

import json
import sys

GOVERNOR_PATH = "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
ICON = ""

ABBREV = {
    "powersave": "pow",
    "performance": "perf",
    "schedutil": "sched",
    "ondemand": "ondmd",
    "conservative": "cons",
}


def get_governor_string():
    with open(GOVERNOR_PATH) as f:
        gov = f.read().strip()
    label = ABBREV.get(gov, gov)
    return f"{ICON} {label}"


def patch_line(line):
    line = line.rstrip("\n")
    if not line.startswith("[") and not line.startswith(","):
        return line

    prefix = ""
    json_part = line
    if line.startswith(","):
        prefix = ","
        json_part = line[1:]

    try:
        blocks = json.loads(json_part)
    except json.JSONDecodeError:
        return line

    gov_str = get_governor_string()
    gov_block = {
        "name": "cpu_governor",
        "full_text": gov_str + " ",
        "short_text": gov_str,
    }

    # Insert after cpu_usage block
    for i, block in enumerate(blocks):
        if block.get("name") == "cpu_usage":
            blocks.insert(i + 1, gov_block)
            break
    else:
        blocks.insert(0, gov_block)

    return prefix + json.dumps(blocks, ensure_ascii=False)


def main():
    print(sys.stdin.readline(), end="")  # {"version":1}
    print(sys.stdin.readline(), end="")  # [

    for line in sys.stdin:
        print(patch_line(line))
        sys.stdout.flush()


if __name__ == "__main__":
    main()
