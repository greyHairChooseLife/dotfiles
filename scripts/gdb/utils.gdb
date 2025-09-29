define rr
    start
    if $_is_pie
        b *main
    else
        b main
    end
end

define retprint
    finish
    print $_
end
document retprint
    현재 함수 실행을 마치고 리턴값을 출력합니다.
end

# (gdb) watch myvar
# - `myvar`가 변경될 때마다 GDB가 자동으로 멈춥니다.


define watchfile
    shell while read var; do echo "watch $var"; done < $arg0 > .gdb_watchcmds
    source .gdb_watchcmds
    shell rm .gdb_watchcmds
end
document watchfile
    watchall <파일명> : 지정한 파일의 각 줄에 대해 watchpoint를 자동으로 설정합니다.
end

define contextwatchfile
    shell while read var; do echo "contextwatch $var"; done < $arg0 > .gdb_watchcmds
    source .gdb_watchcmds
    shell rm .gdb_watchcmds
end
document contextwatchfile
    contextwatchfile <파일명> : 지정한 파일의 각 줄에 watchpoint를 걸고 contextwatch를 활성화합니다.
end

alias wa = watch
alias waf = watchfile
alias cwf = contextwatchfile

# record 실행 시점부터 되감기가 가능하다.
# tmux로 단축키 만들어둠



# ### 1. pwndbg의 `vmmap` 명령

# pwndbg에서는 아래 명령으로 메모리 맵을 볼 수 있습니다.

# ```
# (gdb) vmmap
# ```
# - Stack, Heap, libc, code 등 각 영역의 시작/끝 주소와 권한이 표시됩니다.

# 특정 주소가 어디에 속하는지 확인하려면:

# ```
# (gdb) vmmap 0x주소
# ```
# - 해당 주소가 포함된 영역의 정보를 보여줍니다.

# ---

# ### 2. GDB의 `info proc mappings`

# ```
# (gdb) info proc mappings
# ```
