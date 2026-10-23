# shell-history

zsh 히스토리 저장소(`~/.zsh_history_dir`)를 읽고 쓰는 helper. 함수로 만들면 zsh subshell로
export되지 않아 실행 파일로 둔다.

`dot-config/zsh.sub/history.zsh`의 fzf 바인딩이 `zsh-history list-process`, `delete-process`를 호출한다.

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/zsh-history` | `list-process` / `delete-process` 서브커맨드 |
| `install.sh` | `bin/*`를 `~/.local/bin`으로 링크 |
| `uninstall.sh` | 링크 제거 |
