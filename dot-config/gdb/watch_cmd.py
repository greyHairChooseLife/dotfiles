import gdb

WATCH_HELP = """wa <expr>         : watchpoint on expression (stops on change)
wa -f <path>      : watchpoint per line of <path>
cw <expr>         : show expression live in pwndbg context (no stopping)
cw -e <cmd>       : run <cmd> as a gdb command, shown live (quotes optional)
cw -f <path>      : contextwatch per line of <path>
remove with: cunwatch / contextunwatch / delete"""

WATCH_FILE_SAMPLE = """# cw -f / wa -f file: one contextwatch argument per line.
# Each line runs as: contextwatch <line>
# Blank lines and lines starting with '#' are skipped.

# --- eval: show a value inline ---
# eval lines with spaces must be quoted, otherwise argparse reads the first
# token as the eval/execute mode.
counter
items[0]
"*(int *)$rsp"

# --- execute: run a gdb command, output shown below the header ---
execute "info args"
execute "bt 5"
execute "x/8xg $rsp"

# --- pipe: post-process a gdb command through a shell command ---
execute "pipe disassemble | head -20"
execute "pipe info registers | grep rax"
"""


def _apply(cmd, line):
    line = line.strip()
    if not line or line.startswith("#"):
        return
    try:
        gdb.execute(f"{cmd} {line}")
    except gdb.error as e:
        print(f"{cmd} {line}: {e}")


def _run_file(cmd, path):
    try:
        with open(path) as f:
            for line in f:
                _apply(cmd, line)
    except FileNotFoundError:
        if cmd != "contextwatch":
            print(f"{cmd}: -f: {path}: no such file")
            return
        with open(path, "w") as f:
            f.write(WATCH_FILE_SAMPLE)
        print(f"{cmd}: -f: no such file, wrote sample to {path}")
    except OSError as e:
        print(f"{cmd}: {e}")


def _run(cmd, arg):
    arg = arg.strip()
    if not arg:
        print(WATCH_HELP)
        return

    mode, _, rest = arg.partition(" ")
    rest = rest.strip()

    if mode == "-f":
        if not rest:
            print(f"{cmd}: -f requires a file path")
            return
        _run_file(cmd, rest)
        return

    if mode == "-e":
        if not rest:
            print(f"{cmd}: -e requires a gdb command")
            return
        if not (rest.startswith('"') and rest.endswith('"')):
            rest = f'"{rest}"'
        _apply(cmd, f"execute {rest}")
        return

    try:
        gdb.execute(f"{cmd} {arg}")
    except gdb.error as e:
        print(f"{cmd} {arg}: {e}")


class WaCommand(gdb.Command):
    """wa <expr> | wa -f <path>

    watchpoint on expression, or one per line of file (-f)."""

    def __init__(self):
        super().__init__("wa", gdb.COMMAND_BREAKPOINTS, gdb.COMPLETE_SYMBOL)

    def invoke(self, arg, tty):
        _run("watch", arg)


class CwCommand(gdb.Command):
    """cw <expr> | cw -e <cmd> | cw -f <path>

    contextwatch: show expression live in pwndbg context, no stopping.
    -e runs a gdb command (quotes optional), -f loads one per line."""

    def __init__(self):
        super().__init__("cw", gdb.COMMAND_SUPPORT, gdb.COMPLETE_SYMBOL)

    def invoke(self, arg, tty):
        _run("contextwatch", arg)


WaCommand()
CwCommand()
