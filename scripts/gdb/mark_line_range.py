"""Mark the current source line's instruction range in the disasm context.

Wraps pwndbg's `disasm` section so the instructions belonging to the source
line at $pc are enclosed between two separator rows:

    b► 0x...13c <main+8>   movl   $1, -4(%rbp)
     0x...143 <main+15>  movl   -4(%rbp), %eax

becomes

    ┌───────────────────────────────
    b► 0x...13c <main+8>   movl   $1, -4(%rbp)
    └───────────────────────────────

The green corner caps mark start and end, and the rule fills the rest of the
pane width so the enclosure lines up with the section banner. The range comes
from `info line <file>:<line>`. A single cap pair is used whether the range
holds one instruction or many, so the enclosure never changes shape.
Controlled by `mark-line-range` (on by default).
"""

import re
import sys

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

# The rule spans the pane width, resolved the same way the section banner
# resolves it: an explicit width if the section sets one, otherwise the
# terminal size. The section settings store `False` (not `None`) when no fixed
# width is configured, so treat any non-positive value as "auto".
def _mark_width(target, width):
    try:
        width = int(width)
    except (TypeError, ValueError):
        width = 0
    if width <= 0:
        _height, width = pwndbg.ui.get_window_size(target)
    return max(int(width), 2)


def _cap(corner, width):
    """Green corner cap plus a rule filling the rest of the pane width."""
    return pwndbg.color.green(corner + "\u2500" * (width - 1))


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


def _mark(lines, width):
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

    last = start_idx if end_idx is None else end_idx
    lines.insert(start_idx, _cap("\u250c", width))
    lines.insert(last + 2, _cap("\u2514", width))
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
            target = kwargs.get("target", sys.stdout)
            width = kwargs.get("width")
            return _mark(lines, _mark_width(target, width))
        except Exception:
            return lines

    # pwndbg derives the settable section names from the function __name__
    # ("context_" is stripped), so this must keep the original name or `disasm`
    # disappears from `context-sections`.
    _marked_disasm.__name__ = _original_disasm.__name__

    context.context_sections["d"] = _marked_disasm
