
## setup

```bash
git clone https://github.com/greyHairChooseLife/dotfiles

cd dotfiles

bash stow.sh
```

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



## manage files

1. `$HOME`에 넣을 것은 최상위 경로에 만든다.
2. `$HOME/.config` 경로에 넣을 것은 `dot-config/`에 넣는다.
3. 새로운 config을 추가하면 `stow.sh`에 적용/반영 커맨드를 추가한다.

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
└── stow.sh                   # stow script
```



## Todo


2. $HOME/.config 내 다른 것들
1. bash 완성
3. nvim  packer to lazy

### TMUX

- feat: add tmuxinator
- default path를 확인하는 방법, 그냥 new pane 하면 자꾸 특정 path가 열린다.


#### reference

- 쉘 스크립트 실행해서 리턴값을 사용자 변수에 넣기

    ```tmux
    set -g @current_mode_indicator '#(bash $TMUX_CONFIG_DIR/utils/generate_mode_sign.sh "#{@current_mode}")'
    ```


### NVIM

- packer to lazy
- `C-e` cmp 없애는건 되는데 copilot suggestion 날리는 것은 안된다. nvim-cmp mapping에서 fallback으로 마무리하는게 이 기능 아니었던가? 중간 분기점에서 막히나?
- `C-s` 마찬가지로 Avante input에서 insert-mode 시 prompt 날려주는 단축키로 작동 안한다.
- new plugin: [gitgraph](https://github.com/isakbm/gitgraph.nvim)

- diagnostic sign change: 

- (remove) under-curl
- (add) linenumber highlight


- render-markdown에서 'link' 항목 개선하자. 플러그인에서 기본 제공하는 링크 구분(github 등) 외에도 가장 기본 기능인 hyper link 기능을 구분하자.
  
  내가 앞으로 만드는 문서들은 본문급인 index.md가 있고, 본문에 첨부될 매우 구체적인 노트 조각들도 있다. 이 조각들과 본문을 구분하는건데, 앞의 아이콘을 이용하자.
  구분자로는 `path`가 "1.Project, 2.Area, 3.... "와 같은 문자로 시작되는지 보거나, 파일명이 index.md인지 아닌지만 봐도 좋을 것 같다.


- visual select에서 대문자 S 입력하면 이후 연속해서(sequence) 입력하는 문자에 따라 다양한 기능을 제공한다. 이게 뭔지 알아보자.

### i3-WM

1. `mod-q` update

```bash
if current_process_is_tmux then
    save_tmux_resurrect()
    kill process
else
    kill process
end
```

