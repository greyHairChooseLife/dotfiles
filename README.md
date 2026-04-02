## how to start?

```bash
git clone https://github.com/greyHairChooseLife/dotfiles

cd dotfiles

bash setup.sh
```


## manage files

1. `$HOME`에 넣을 것은 최상위 경로에 만든다.
2. `$HOME/.config` 경로에 넣을 것은 `dot-config/`에 넣는다.
3. 새로운 config을 추가하면 `setup.sh`에 적용/반영 커맨드를 추가한다.

```bash
# tree -a ~/dotfiles

dotfiles/
├── deprecated                # ignored by stow, since dir name is 'deprecated'. `.stow-local-ignore` rules this
├── .dmenurc                  # this level goes to $HOME
├── dot-config                # this level goes to $HOME/.config
│   ├── deprecated            # ignored by stow
│   │   └── ignore_test       
│   └── dunst
│       └── dunstrc
├── README.md                 
├── .stow-local-ignore        # stow ignore rules
└── setup.sh                   # stow script
```


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


