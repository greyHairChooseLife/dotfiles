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

1. `$HOME`에 넣을 것은 최상위 경로에 만든다.
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
├── .dmenurc                  # 이 레벨은 $HOME으로 링크된다
├── dot-config                # $HOME/.config  (외부 앱 설정)
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
| `picker` | fzf 선택 → tmux pane에 경로 입력 (`cc_file_picker`, `find_file_tmux`, `rg_picker`) |
| `code-search` | 검색 결과를 nvim으로 (`rg_fzf_search`, `sg_fzf_search`) |
| `keyboard` | 내장/BT 키보드 전환 (`btkb`) |
| `lid` | suspend 시 taskwarrior 보고서, resume 시 floating nvim |
| `shell-history` | zsh 히스토리 helper (`zsh-history`) |
| `task` | taskwarrior 보조 (`task-timespent`, cheatsheet) |
| `git-worktree` | worktree용 tmux 창 배치 |
| `system-tuning` | CPU governor / TLP / EPP udev 규칙 |
| `misc` | `txt2pdf`, 파일·docker 이미지 공유 |
| `study-english` | 사전 조회 (`dictionary`) + 학습 노트 생성 참고 구현 |

feature 안에서 다른 feature의 helper를 쓰면 안 된다. 공용이면 `features/base`로 올린다.


## Tmux

### REFERENCE

> You can capture the current window layout using display-message
> 
> layout=$( tmux display-message -p "#{window_layout}" ) Note that this
> works in tmux version 1.7 or later. If you are using an older version, you
> could try extracting the layout string from the list-windows command. One way
> to do it is as follows:
> 
> layout=$( tmux list-windows | sed -e 's/^.*\[layout \(\S*\)].*$/\1/' )
> and now you can use that variable, to restore your layout at a later time,
> with select-layout:
> 
> tmux select-layout "$layout"


### tmux plugins 관리: 어떻게 서브모듈 방식을 극복할 것인가? [-]

[-] 아래 방식으로 잘 기능하긴 한다. 그러나 내 나름대로 환경변수를 활용해서 시도하니 그건 또
안된다. 이 부분 개선하고 아래 내용을 커버업 하자.

> [!rf]
> 
> [source](https://gitlab.com/-/snippets/3679805)
> ```txt
> Assume Stow directory is ~/dotfiles (already under version control with Git), and you already have a ~/.tmux.conf file
> 
> Make sure GNU Stow is installed
> mkdir -p ~/dotfiles/tmux/.config/tmux
> mv ~/.tmux.conf ~/dotfiles/tmux/.config/tmux/tmux.conf
> Run stow to set up link for Tmux config file, stow -D ~/dotfiles tmux
> Create an install directory for TPM managed plugins, mkdir -p ~/.local/bin/tmux/plugins
> Install TPM git clone https://github.com/tmux-plugins/tpm ~/.local/bin/tmux/plugins/tpm
> Edit the Tmux configuration file (now called ~/dotfiles/tmux/.config/tmux/tmux.conf) and modify to reflect the content below
> Run $HOME/.local/bin/tmux/plugins/tpm/bin/install_plugins to install the plugins.
> Add changes to version control with cd ~/dotfiles && git add tmux && git commit -m "Added Tmux config" && git push
> To update plugins run $HOME/.local/bin/tmux/plugins/tpm/bin/update_plugins all.
> 
> Credits:
> 
> A lot of this was based on material from Josean Martinez and Brandon Invergo. See references below.
> 
> References:
> 
> https://www.josean.com/posts/tmux-setup
> https://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html
> https://github.com/tmux-plugins/tpm/blob/master/docs/tpm_not_working.md
> https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
> https://github.com/tmux-plugins/tpm/issues/114#issuecomment-315960729
> ```

### 쉘 스크립트의 리턴값을 tmux 사용자 변수에 넣기

```tmux
set -g @current_mode_indicator '#(bash $TMUX_CONFIG_DIR/utils/generate_mode_sign.sh "#{@current_mode}")'
```


