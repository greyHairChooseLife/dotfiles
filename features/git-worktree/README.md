# git-worktree

git worktree 디렉토리에서 tmux 창 레이아웃을 만든다. 현재 디렉토리 이름에서 창 이름을 유도하고,
편집·빌드·터미널 pane을 배치한다. zsh alias `cw`가 호출한다.

## 구조

| 경로 | 역할 |
| --- | --- |
| `bin/create_action_worktree_tmux_window` | 창 생성 |
| `install.sh` | `bin/*`를 `~/.local/bin`으로 링크 |
| `uninstall.sh` | 링크 제거 |
