# gdb

GDB 설정과 add-on. `gdbinit`은 `~/.config/gdb/gdbinit`으로 링크되고, add-on은 같은 디렉토리에서
`source`된다. GDB 18은 XDG 경로(`~/.config/gdb/gdbinit`)를 읽으므로 `~/.gdbinit`은 쓰지 않는다.

pwndbg를 전제로 하지만, 없으면 경고만 남기고 나머지는 그대로 로드한다. add-on 하나가 실패해도
나머지는 계속 로드된다.

## add-on

| 파일 | 추가되는 것 |
| --- | --- |
| `layout.py` | context 창 레이아웃 조정 (pwndbg) |
| `mark_line_range.py` | 현재 소스 라인에 해당하는 명령어 구간을 disasm에서 구분 표시 (pwndbg) |
| `watch_cmd.py` | `wa` (watchpoint), `cw` (context에 식을 계속 표시), `cunwatch` / `contextunwatch` |
| `utils.gdb` | `rr` (PIE 여부에 맞춰 `main`에 브레이크포인트 후 `start`) |
| `mapaddr.py` | `mapaddr EXPR`: 주소가 속한 매핑 영역을 찾아 표시 |

## 확인

```bash
gdb -q -batch -ex 'help rr' -ex 'help mapaddr' -ex 'help wa'
```

로드 상태를 보려면 `gdb` 실행 직후 `gdb: skipped ...` 경고가 없는지 본다.
