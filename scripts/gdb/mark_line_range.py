"""Mark the instruction range of the current source line in the disasm context.

Wraps pwndbg's `disasm` section so the instructions belonging to the source
line at $pc are enclosed in a bracket:

    ┌─ 0x...13c  <main+8>   movl  $1, -4(%rbp)
      0x...143  <main+15>  movl  -4(%rbp), %eax
    └─

The range comes from `info line <file>:<line>`, the same lookup used by the
standalone `disassemble` reprint this replaces. Ranges are typically 1-3
instructions, and $pc is always the range start, so a single-instruction
range collapses to a single marker pair on one line.

Controlled by `mark-line-range` (on by default).
"""

import re

import gdb

import pwndbg
import pwndbg.color
import pwndbg.commands.context as context

# `pwndbg.config.add_param` asserts the name is unused, and re-sourcing this
# file must stay safe, so reuse an already registered parameter if present.
mark_line_range = pwndbg.config.params.get("mark_line_range")
if mark_line_range is None:
    mark_line_range = pwndbg.config.add_param(
        "mark-line-range",
        True,
        "enclose the current source line's instructions in the disasm context",
    )

LINE_RANGE_RE = re.compile(
    r"starts at address (0x[0-9a-fA-F]+).+ends at (0x[0-9a-fA-F]+)"
)
ADDR_RE = re.compile(r"0x[0-9a-fA-F]+")

START_MARK = pwndbg.color.green("\u250c\u2500 ")  # ┌─
END_MARK = pwndbg.color.green("\u2514\u2500 ")  # └─
SOLO_MARK = pwndbg.color.green("\u2500\u2500 ")  # ──

# pwndbg creates the `set`/`show` commands for its parameters once, at
# bootstrap. A parameter added afterwards (like ours) is registered but has no
# command, so create one for it. Guarded because GDB rejects a duplicate
# `set`/`show` name, which would break re-sourcing this file.
def _ensure_set_show_command():
    try:
        gdb.execute("show mark-line-range", to_string=True)
        return  # already registered
    except gdb.error:
        pass
    from pwndbg.gdblib.config import Parameter

    Parameter(mark_line_range)


_ensure_set_show_command()


def _current_line_range():
    """Return (start, end) addresses for the source line at $pc, or None."""
    try:
        frame = gdb.selected_frame()
    except gdb.error:
        return None
    if frame is None:
        return None

    sal = frame.find_sal()
    if sal is None or sal.symtab is None:
        return None

    try:
        line_info = gdb.execute(f"info line {sal.symtab.filename}:{sal.line}", to_string=True)
    except gdb.error:
        return None

    m = LINE_RANGE_RE.search(line_info)
    if not m:
        return None
    return int(m.group(1), 16), int(m.group(2), 16)


def _line_address(line):
    """Return the instruction address a disasm line starts with, or None.

    Lines carry ANSI color codes and may open with a gutter glyph, so match the
    first hex address anywhere in the line rather than anchoring.
    """
    m = ADDR_RE.search(line)
    if not m:
        return None
    return int(m.group(0), 16)


def _mark(lines):
    rng = _current_line_range()
    if rng is None:
        return lines
    start, end = rng

    start_idx = end_idx = None
    for i, line in enumerate(lines):
        addr = _line_address(line)
        if addr is None:
            continue
        if start_idx is None and addr == start:
            start_idx = i
        if addr == end - 1:
            end_idx = i

    # `end` is exclusive and may not correspond to a real instruction in the
    # window; fall back to the last line whose address is below it.
    if end_idx is None:
        for i, line in enumerate(lines):
            addr = _line_address(line)
            if addr is not None and start <= addr < end:
                end_idx = i

    if start_idx is None:
        return lines

    if end_idx is None or end_idx == start_idx:
        # Single-instruction range: one self-contained marker.
        lines[start_idx] = SOLO_MARK + lines[start_idx]
        return lines

    lines[start_idx] = START_MARK + lines[start_idx]
    lines[end_idx] = END_MARK + lines[end_idx]
    return lines


_original_disasm = context.context_sections.get("d")

# Sourcing this file twice must not wrap the wrapper (that would recurse), so
# stash the original function once and reuse it.
_original_disasm = globals().setdefault("_mark_saved_disasm", _original_disasm)

if _original_disasm is not None:

    def _marked_disasm(*args, **kwargs):
        lines = _original_disasm(*args, **kwargs)
        if not mark_line_range:
            return lines
        try:
            return _mark(lines)
        except Exception:
            return lines

    # pwndbg derives the settable section names from the function __name__
    # ("context_" is stripped), so this must keep the original name or `disasm`
    # disappears from `context-sections`.
    _marked_disasm.__name__ = _original_disasm.__name__

    context.context_sections["d"] = _marked_disasm
