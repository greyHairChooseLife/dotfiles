## how to start?

```bash
git clone https://github.com/greyHairChooseLife/dotfiles

cd dotfiles

bash setup.sh
```

인자 없이 실행하면 단계(숫자)와 feature(알파벳) 목록을 보여주고 선택을 받는다.
일부만 다시 실행할 때는 인자로 지정한다.

```bash
./setup.sh 5              # stow만
./setup.sh b-d            # feature code-search ~ keyboard
./setup.sh -e             # feature lid 비활성화
./setup.sh unstow         # 링크 제거
```


## manage files

1. `$HOME`에 넣을 것은 최상위 경로에 만든다. 파일명은 `dot-*`로 쓰고 stow `--dotfiles`가 앞의 `dot-`을 `.`으로 바꾼다 (`dot-zshrc` → `~/.zshrc`).
2. `$HOME/.config` 경로에 넣을 것은 `dot-config/`에 넣는다.
3. 새로운 config을 추가하면 `setup.sh`에 적용/반영 커맨드를 추가한다.
4. 외부 앱 설정이 아니라 **직접 만든 동작**(설치 단계·sudo·상태·의존이 있는 것)은 `features/<name>/`에 둔다.
   - 규격: `README.md`(첫 줄이 설명) + `install.sh`(`--status` 지원, 멱등) + `uninstall.sh` + `bin/*` + `libexec/*`
   - `bin/*` → `~/.local/bin`, `libexec/*` → `~/.local/libexec/<name>`
   - feature 끼리 쓰는 기반 기능은 `features/base`에 두고 `require_feature`로 의존을 선언한다
   - `setup.sh`가 `features/*/install.sh`를 순회하며 설치 여부를 묻는다

```bash
# tree -a ~/dotfiles

dotfiles/
├── .stow-local-ignore        # stow ignore 규칙 ('deprecated' 등 제외)
├── dot-*                     # 이 레벨은 $HOME으로 링크된다 (dot-zshrc -> .zshrc)
├── dot-config                # $HOME/.config  (외부 앱 설정)
├── dot-pi                    # $HOME/.pi     (pi 에이전트 설정, skills/extensions 포함)
├── features                  # 설치/해제 단위 (아래 표)
├── setup.d                   # setup.sh 단계별 스크립트 (yay, mirror, packages)
├── devbox                    # 개발 컨테이너
├── README.md
└── setup.sh                  # stow + feature 설치
```

## features

| name | 내용 |
| --- | --- |
| `base` | 공용 기반: `find_file`, `show_spinner` |
| `picker` | fzf 선택 → tmux pane에 경로 입력 (`cc_file_picker`, `find_file_tmux`, `rg_picker`), 디렉토리 이동 (`find_dir`) |
| `code-search` | 검색 결과를 nvim으로 (`rg_fzf_search`, `sg_fzf_search`) |
| `keyboard` | 내장/BT 키보드 전환 (`btkb`) |
| `lid` | suspend 시 taskwarrior 보고서, resume 시 floating nvim |
| `shell-history` | zsh 히스토리 helper (`zsh-history`) |
| `task` | taskwarrior 보조 (`task-timespent`, cheatsheet) |
| `git-worktree` | worktree용 tmux 창 배치 |
| `system-tuning` | CPU governor / TLP / EPP udev 규칙 |
| `misc` | `txt2pdf`, 파일·docker 이미지 공유 |
| `vocal` | 녹음 → 전사 (whisper 또는 OpenAI API) |
| `study-english` | 사전 조회 (`dictionary`) + 학습 노트 생성 참고 구현 |

feature 안에서 다른 feature의 helper를 쓰면 안 된다. 공용이면 `features/base`로 올린다.
