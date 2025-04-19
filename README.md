


## how to start?

```bash
git clone https://github.com/greyHairChooseLife/dotfiles

cd dotfiles

bash stow.sh
```


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


## Tmux

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




## Comming soon..

[rainfrong: TUI DB](https://github.com/achristmascarl/rainfrog)


## Todo - etc


> [!ye] tmux
>
> - feat: add tmuxinator
> - default path를 확인하는 방법, 그냥 new pane 하면 자꾸 특정 path가 열린다.




> [!ye] i3-WM
>
> - `mod-q` update
>
>   ```bash
>   # 의사코드
>   if current_process_is_tmux then
>       save_tmux_resurrect()
>       kill process
>   else
>       kill process
>   end
>   ```


## NVIM

### 읽을것 읽기

5개 링크

- https://github.com/jmacadie/telescope-hierarchy.nvim
- https://www.reddit.com/r/neovim/comments/1h25lal/what_are_your_favorite_underappreciated_neovim/


### etc


- <leader>s로 검색하는 기능의 확장으로,
  papago api따위를 활용하여 번역 후 결과를 작은 floating window로 띄우기

- 파이썬 formmat 되긴 하는거야? ruff 말이야.


- ~/REF 보고 따라하자. 구조 좋은거 그거로



### codecompanion

- /workspace with vectorcode plugin [ref](https://codecompanion.olimorris.dev/extending/workspace.html)

- mcp!

### 관심있는 플러그인

- [snacks.scope](https://github.com/folke/snacks.nvim/blob/main/docs/scope.md)
  : 조건문, 반복문 등도 treesitter에 등록시켜주나? 그래서 aerial에서도 확인 할 수 있나?

- new plugin: [gitgraph](https://github.com/isakbm/gitgraph.nvim)

- image on buffer: [github 1](https://github.com/Toprun123/PicVim) & [github 2](https://github.com/Skardyy/neo-img)

- `folke/trouble.nvim`
  coc.nvim과 함게는 쓰기 어렵고, 내장 lsp 매니저(?)로 전환할 때 활용하자

- http client inside neovim

  - https://github.com/rest-nvim/rest.nvim
  - https://www.reddit.com/r/neovim/comments/1eh0yr6/restnvim_is_back/
  - https://github.com/mistweaverco/kulala.nvim

- indent or chunk marker(visualizer)

  - https://github.com/shellRaining/hlchunk.nvim

- crawling web pages, rendering them to Markdown or JSON, and inserting the content into new buffers. It also supports asynchronous search functionality.

  - https://github.com/twilwa/crawler.nvim

- 선택한 코드라인의 github url을 생성

  - https://www.reddit.com/r/neovim/comments/1gzid9o/browshernvim_create_commit_pinned_githubgitlab/
  - https://github.com/claydugo/browsher.nvim

- smooth scroll without neovide or kitty + smear cursor
    - from reddit

- jremmen/vim-ripgrep	
  ```lua
  "jremmen/vim-ripgrep",
      cmd = "Rg",
      init = function()
        vim.keymap.set("n", "<C-h>", ":Rg<space>")
        vim.keymap.set("n", "<C-*>", "<cmd>Rg<space><CR>")
        vim.keymap.set("n", "<C-g>", "<cmd> lua require('utils').replace_grep()<CR>")
      end,
  ```

- [scope.nvim](https://github.com/tiagovla/scope.nvim)
  원래는 tab과 buffer는 별 관련이 없다. 근데 텝마다 별도의 buffer그룹을 가졌으면... 하고 생각할 때가 있다. 이런 아이디어를 구현한 플러그인


- Aider plugins
  https://github.com/GeorgesAlkhouri/nvim-aider
  https://github.com/joshuavial/aider.nvim
  https://github.com/aweis89/aider.nvim


### config 훔치기 [-]

leader gc해서 커밋 메시지 켤 때 뭐 이상해진다. 가끔. 윈도우 자리가 안맞음

- 전반적으로
  https://patrick-f.tistory.com/36

- 구조는 reference에 있는 중국인 양반것이 매우 좋아 보임
  - 내가 임의로 만든 작은 단위의 기능들은 각 카테고리 안에 `modules/`라고
    만들어서 기능당 하나의 lua파일에 담아서 관리해야겠다.

### 개선서항 [-]

#### 간단

- `<leader>cc`로 commitmsg 버퍼를 켜면 최종 버퍼의 포키싱 윈도우 범위가 바뀐다.(살짝 올라감)
- auto-session 복구시 탭 이름도 복구 되도록
- keymap: telescope 에서 <C-q>로 선택한 파일을 qf에 추가한다. 근데 이거 곧바로 qflist 버퍼를 띄우기보단 그냥 log만 남겨주는게 좋을듯

- `Tab, S-Tab, g-Tab`으로 버퍼 순회할 때 현재 탭의 윈도우에 active인 것은 제외해도 되겠다. 그리고 이것이 시각적으 로표현되도록 하면 좋겠다.
    [ref](https://www.youtube.com/watch?v=ST_DZ6yIiXY)

- winbar의 활용

- visual select에서 대문자 S 입력하면 이후 연속해서(sequence) 입력하는 문자에 따라 다양한 기능을 제공한다. 이게 뭔지 알아보자.

#### 복잡

- nvim-tree에서 지금 주황색으로 보여주고 표시하는건 loaded buffer인데, 현재탭의 active window만 보는것도 좋을것같다.    
  정리해보면 not-loaded(기본 트리)/ loaded/ active(cucrent tab) / left(== inactive in current tab)을 한눈에 볼 파악할 수 있는 tree가 있다면 유용하겠다.(ex: avante.nvim selected file에 active 파일들을 모두 추가)

- 현재 tab에서 loaded / inactive / active 버퍼 리스트를 얻을 수 있는 나만의 utils를 만들어두면 좋겠다. 
  -> scope.nvim

### 버그

- harpoon으로 열린 버퍼는 BufReadPost로 실행하고있는 :loadview가 제대로 안된다. cursor_position등 정보를 harpoon이 별도로 저장하고 사용해서 그런듯.
