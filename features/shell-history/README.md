# shell-history

zsh 히스토리 저장소(`~/.zsh_history_dir/history`)를 읽고 쓰는 helper. 함수로 만들면 zsh subshell로
export되지 않아 실행 파일로 둔다.

`dot-config/zsh.sub/history.zsh`의 fzf 바인딩과 shell 시작 훅이 `zsh-history`를 호출한다.

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/zsh-history` | list / delete / trim / import-legacy 서브커맨드 |
| `install.sh` | `bin/*`를 `~/.local/bin`으로 링크 |
| `uninstall.sh` | 링크 제거 |

## 저장소

`~/.zsh_history_dir/history` 한 파일에 명령 하나당 한 줄:

```
timestamp<TAB>pid<TAB>pwd<TAB>command
```

-   shell마다 파일을 만들던 예전 구조(`pid_<pid>`)는 `zsh-history import-legacy`가 한 번에 접어 넣는다.
    shell 시작 시 백그라운드로 실행되고, 옮길 파일이 없으면 즉시 끝난다.
-   추가는 `save_successful_history`가 `flock`을 잡고 `>>`로 한다. `trim` / 삭제는 같은 inode를
    잠근 채 제자리에서 덮어쓰므로, 동시에 들어오는 append가 사라지지 않는다.
-   `trim [max]`는 오래된 줄부터 버려 최근 `max`(기본 50000)개만 남긴다.

## 서브커맨드

| 커맨드 | 설명 |
| --- | --- |
| `list-process [--no-path] [--reverse] [pid]` | 해당 shell 프로세스의 히스토리 |
| `list-global [--no-path] [--reverse]` | 전체 히스토리 (명령별 최신 1개로 중복 제거) |
| `delete-process <pid> [--ask] <entry>...` | 해당 프로세스에서만 제거 |
| `delete-global [--ask] <entry>...` | 모든 프로세스에서 제거 |
| `trim [max]` | 최근 `max`줄만 남김 |
| `import-legacy` | 예전 `pid_*` 파일을 저장소로 흡수 |

`--ask`는 `/dev/tty`에서 확인을 받는다(fzf `execute(...)` 안에서도 동작). 터미널이 없으면 그냥 진행한다.
`--reverse`는 최신순 정렬이며, fzf에는 `--tac` 대신 이걸 쓴다(`--track`과 `--tac`을 같이 쓰면
커서가 목록 끝에서 시작한다).
