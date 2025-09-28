source /usr/share/pwndbg/gdbinit.py

set context-clear-screen on
set disassembly-flavor att
set context-output tty
set show-tips off

set chain-arrow-left 
set chain-arrow-right 

# 부모 프로세스 계속 추적
# set follow-fork-mode parent

set print pretty on
set backtrace limit 0
set logging file dbg.log
set logging enabled on

# pwndbg: 스택이 위에서 아래로 자라게 표시 외?않?되?
# set context-stack-lines-reverse on

source /home/sy/dotfiles/scripts/gdbinit.py

