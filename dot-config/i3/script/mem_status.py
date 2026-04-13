#!/usr/bin/env python3
"""
i3status memory output patcher.
Replaces M:%used/%total with btop-style calculation:
  used = MemTotal - MemAvailable (matches btop)
"""

import json
import sys


def read_meminfo():
    fields = {}
    with open("/proc/meminfo") as f:
        for line in f:
            key, val = line.split(":")
            fields[key.strip()] = int(val.split()[0])  # kB
    return fields


def format_mem(kb):
    gib = kb / (1024**2)
    if gib >= 1:
        return f"{gib:.1f}G"
    mib = kb / 1024
    return f"{mib:.0f}M"


def get_mem_string():
    m = read_meminfo()
    total = m["MemTotal"]
    used = total - m["MemAvailable"]
    return f"M:{format_mem(used)}/{format_mem(total)}"


def patch_line(line):
    line = line.rstrip("\n")
    # i3status outputs JSON arrays (one per tick) after two header lines
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

    mem_str = get_mem_string()
    for block in blocks:
        if block.get("name") == "memory":
            block["full_text"] = mem_str + " "
            block["short_text"] = mem_str
    return prefix + json.dumps(blocks, ensure_ascii=False)


def main():
    # Print the two header lines as-is
    print(sys.stdin.readline(), end="")  # {"version":1}
    print(sys.stdin.readline(), end="")  # [

    for line in sys.stdin:
        print(patch_line(line))
        sys.stdout.flush()


if __name__ == "__main__":
    main()
