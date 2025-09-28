import atexit
import os
import sys

import pwndbg
from pwndbg.commands.context import contextoutput


def create_tmux_pane(command):
    """Create a tmux pane and return [pane_id, pane_tty] or None on error."""
    try:
        result = os.popen(command).read().strip()
        if result:
            return result.split(":")
        return None
    except Exception as e:
        print(f"Error creating tmux pane: {e}", file=sys.stderr)
        return None


def setup_panes():
    """Setup tmux panes for pwndbg context display."""
    panes = {}

    # Create main top pane (75% height) for disasm and regs
    main_top = create_tmux_pane(
        'tmux split-window -vb -P -F "#{pane_id}:#{pane_tty}" -l 75% -d "cat -"'
    )
    if not main_top:
        print("Failed to create main top pane", file=sys.stderr)
        return {}

    panes["disasm"] = main_top

    # Split the main top pane vertically for registers (30% width)
    regs_pane = create_tmux_pane(
        f'tmux split-window -h -P -F "#{pane_id}:#{pane_tty}" -t {main_top[0]} -l 30% -d "cat -"'
    )
    if regs_pane:
        panes["regs"] = regs_pane

    # Split the bottom area horizontally for stack (60% height of bottom area)
    stack_pane = create_tmux_pane(
        'tmux split-window -v -P -F "#{pane_id}:#{pane_tty}" -l 60% -d "cat -"'
    )
    if stack_pane:
        panes["stack"] = stack_pane

    # Split stack pane vertically for backtrace (30% width)
    backtrace_pane = create_tmux_pane(
        f'tmux split-window -h -P -F "#{pane_id}:#{pane_tty}" -t {stack_pane[0]} -l 30% -d "cat -"'
    )
    if backtrace_pane:
        panes["backtrace"] = backtrace_pane

    # Split the remaining bottom area for stdio and ipython
    stdio_pane = create_tmux_pane(
        'tmux split-window -h -P -F "#{pane_id}:#{pane_tty}" -l 60% -d "cat -"'
    )
    if stdio_pane:
        panes["stdio"] = stdio_pane

    # Create ipython pane in remaining space
    ipython_pane = create_tmux_pane(
        'tmux split-window -h -P -F "#{pane_id}:#{pane_tty}" -d "ipython"'
    )
    if ipython_pane:
        panes["ipython"] = ipython_pane

    return panes


def setup_panes():
    """Setup tmux panes for pwndbg context display."""
    panes = {}

    # Step 1: Create top pane (disasm) - 75% height from bottom
    disasm_pane = create_tmux_pane(
        'tmux split-window -vb -P -F "#{pane_id}:#{pane_tty}" -l 75% -d "cat -"'
    )
    if not disasm_pane:
        print("Failed to create disasm pane", file=sys.stderr)
        return {}
    panes["disasm"] = disasm_pane

    # Step 2: Split disasm pane vertically for registers (30% width from right)
    regs_pane = create_tmux_pane(
        f'tmux split-window -h -P -F "#{pane_id}:#{pane_tty}" -t {disasm_pane[0]} -l 30% -d "cat -"'
    )
    if regs_pane:
        panes["regs"] = regs_pane

    # Step 3: Split current (bottom) pane vertically for stack (60% height)
    stack_pane = create_tmux_pane(
        'tmux split-window -v -P -F "#{pane_id}:#{pane_tty}" -l 60% -d "cat -"'
    )
    if stack_pane:
        panes["stack"] = stack_pane

        # Step 4: Split stack pane horizontally for backtrace (30% width from right)
        backtrace_pane = create_tmux_pane(
            f'tmux split-window -h -P -F "#{pane_id}:#{pane_tty}" -t {stack_pane[0]} -l 30% -d "cat -"'
        )
        if backtrace_pane:
            panes["backtrace"] = backtrace_pane

    # Step 5: Split remaining pane horizontally for stdio (60% width)
    stdio_pane = create_tmux_pane(
        'tmux split-window -h -P -F "#{pane_id}:#{pane_tty}" -l 60% -d "cat -"'
    )
    if stdio_pane:
        panes["stdio"] = stdio_pane

    # Step 6: Start ipython in the remaining pane
    # Get the current pane info first
    current_result = os.popen('tmux display -p "#{pane_id}:#{pane_tty}"').read().strip()
    if current_result:
        current_pane_info = current_result.split(":")
        # Start ipython in current pane
        os.popen(f'tmux send-keys -t {current_pane_info[0]} "ipython" Enter').read()
        panes["ipython"] = current_pane_info

    return panes


# Setup the panes
panes = setup_panes()

if not panes:
    print(
        "Failed to setup tmux panes. Make sure you're running inside tmux.",
        file=sys.stderr,
    )
    sys.exit(1)

# Tell pwndbg which panes are to be used for what
for section, p in panes.items():
    if section == "ipython":
        continue  # Skip ipython pane for context output
    contextoutput(section, p[1], True, "top", False)

# Add additional sections to existing panes
if "stack" in panes:
    contextoutput("legend", panes["stack"][1], True)
if "regs" in panes:
    contextoutput("expressions", panes["regs"][1], True, "top", False)

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
def cleanup_panes():
    """Clean up tmux panes on exit."""
    if panes:  # Only cleanup if panes were created successfully
        for section, p in panes.items():
            try:
                os.popen(f"tmux kill-pane -t {p[0]}").read()
            except Exception as e:
                print(f"Error killing pane {section}: {e}", file=sys.stderr)


atexit.register(cleanup_panes)

if panes:
    print("pwndbg tmux layout initialized successfully!")
    print(f"Created panes: {', '.join(panes.keys())}")
else:
    print("Failed to initialize pwndbg tmux layout", file=sys.stderr)
