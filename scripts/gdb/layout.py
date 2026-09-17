import atexit
import os

import pwndbg
from pwndbg.commands.context import contextoutput

panes = {
    "code": os.popen(
        'tmux split-window -vb -P -F "#{pane_id}:#{pane_tty}" -l 80% -d "cat -"'
    )
    .read()
    .strip()
    .split(":"),
    # Split vertical next to the disassemble for the registers
    "regs": os.popen(
        'tmux split-window -h -P -F "#{pane_id}:#{pane_tty}" -l 45% -t {top-right} -d "cat -"'
    )
    .read()
    .strip()
    .split(":"),
    # Split horizontal to make the main window at the bottom
    "disasm": os.popen(
        # 'tmux split-window -vb -P -F "#{pane_id}:#{pane_tty}" -l 75% -d "tmux set -p @mytitle hoho; cat -"'
        'tmux split-window -v -P -F "#{pane_id}:#{pane_tty}" -l 70% -t {top-left} -d "cat -"'
    )
    .read()
    .strip()
    .split(":"),
    # Split horizontal to make the disasm + regs on the top, stack + stacktrace on bottom
    "backtrace": os.popen(
        'tmux split-window -v -P -F "#{pane_id}:#{pane_tty}" -l 15% -t {top-right} -d "cat -"'
    )
    .read()
    .strip()
    .split(":"),
    # "args" is created after this dict, so it can target the backtrace pane by
    # its pane id rather than a pane index (see below).
    # Split vertical next to the stack for the backtrace
    "stack": os.popen(
        'tmux split-window -v -P -F "#{pane_id}:#{pane_tty}" -l 50% -t {top-right} -d "cat -"'
    )
    .read()
    .strip()
    .split(":"),
    "input & output": os.popen(
        'tmux split-window -h -P -F "#{pane_id}:#{pane_tty}" -l 50% -t {top-left} -d "tty; tail -f /dev/null"'
    )
    .read()
    .strip()
    .split(":"),
    "expressions": os.popen(
        'tmux split-window -h -P -F "#{pane_id}:#{pane_tty}" -l 60% -t {bottom} -d "cat -"'
    )
    .read()
    .strip()
    .split(":"),
    "Ipython": os.popen(
        'tmux split-window -h -P -F "#{pane_id}:#{pane_tty}" -t {bottom} -l 20% -d "ipython --no-banner"'
    )
    .read()
    .strip()
    .split(":"),
    "heap_tracker": os.popen(
        'tmux split-window -h -P -F "#{pane_id}:#{pane_tty}" -t {bottom} -l 20% -d "cat -"'
    )
    .read()
    .strip()
    .split(":"),
}

# `args` sits to the right of the backtrace pane. Target that pane by the id
# captured above instead of a pane index: the old target was `:.+4`, which
# means "four panes after the active one" and shifts whenever a pane is added or
# removed, splitting the wrong pane.
panes["args"] = (
    os.popen(
        f'tmux split-window -h -P -F "#{{pane_id}}:#{{pane_tty}}" '
        f'-l 40% -t {panes["backtrace"][0]} -d "cat -"'
    )
    .read()
    .strip()
    .split(":")
)

# Tell pwndbg which panes are to be used for what
# os.system(f'tmux set-option -t {p[0]} -p @mytitle "{section}"')
for section, p in panes.items():
    contextoutput(section, p[1], True, "bottom", False)
    os.system(f'tmux set-option -t {p[0]} -p @mytitle "{section}"')

# Also add the sections legend and expressions to already existing panes
# contextoutput("code", panes["disasm"][1], True, "top")
contextoutput("legend", panes["regs"][1], True)
# contextoutput("expressions", panes["regs"][1], True, "top", False)

# The "input & output" pane runs `tty; tail -f /dev/null`, and the split above
# captured its device path as panes["input & output"][1]. Point the inferior's
# terminal at that pane by running `tty <path>` at the gdb prompt, so program
# input and output land in the pane.
#
# TMUX_PANE is the pane this process actually runs in, so the command is
# delivered to the gdb pane regardless of which pane is active. This replaces
# an `xdotool type` call that simulated the keystrokes "tty /dev/pts/" into
# whichever X window happened to be focused: that did nothing over ssh, and it
# typed into the wrong window whenever focus was elsewhere.
gdb_pane = os.environ.get("TMUX_PANE")
if gdb_pane:
    io_tty = panes["input & output"][1]
    os.system(f'tmux send-keys -t {gdb_pane} "tty {io_tty}" C-m')

# To see more options to customize run `theme` and `config` in gdb
# Increase the amount of lines shown in disasm and stack
pwndbg.config.context_disasm_lines.value = 25
pwndbg.config.context_stack_lines.value = 18
# Give backtrace a little more color
pwndbg.config.backtrace_prefix_color.value = "red,bold"
pwndbg.config.backtrace_address_color.value = "gray"
pwndbg.config.backtrace_symbol_color.value = "red"
pwndbg.config.backtrace_frame_label_color.value = "green"
# Remove the panes when gdb is exited
atexit.register(
    lambda: [os.popen(f"tmux kill-pane -t {p[0]}").read() for p in panes.values()]
)
