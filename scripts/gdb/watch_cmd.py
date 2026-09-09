import gdb

WATCH_HELP = """wa <expr>         : watchpoint on expression (stops on change)
wa -f <path>      : watchpoint per line of <path>
cw <expr>         : show expression live in pwndbg context (no stopping)
cw -f <path>      : contextwatch per line of <path>
remove with: cunwatch / contextunwatch / delete"""


def _apply(cmd, line):
    line = line.strip()
    if not line or line.startswith("#"):
        return
    try:
        gdb.execute(f"{cmd} {line}")
    except gdb.error as e:
        print(f"{cmd} {line}: {e}")


def _run(cmd, arg):
    args = arg.split()
    if args and args[0] == "-f":
        if len(args) < 2:
            print(f"{cmd}: -f requires a file path")
            return
        try:
            with open(args[1]) as f:
                for line in f:
                    _apply(cmd, line)
        except OSError as e:
            print(f"{cmd}: {e}")
    else:
        if not arg:
            print(WATCH_HELP)
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
    """cw <expr> | cw -f <path>

    contextwatch: show expression live in pwndbg context, no stopping."""

    def __init__(self):
        super().__init__("cw", gdb.COMMAND_SUPPORT, gdb.COMPLETE_SYMBOL)

    def invoke(self, arg, tty):
        _run("contextwatch", arg)


WaCommand()
CwCommand()
