# dotfiles


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


## Tips

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
[yazi: TUI File Manager](https://github.com/sxyazi/yazi)


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


## Todo - nvim


### 관심있는 플러그인

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

- chat with copilot

  - https://github.com/CopilotC-Nvim/CopilotChat.nvim?tab=readme-ov-file

- crawling web pages, rendering them to Markdown or JSON, and inserting the content into new buffers. It also supports asynchronous search functionality.

  - https://github.com/twilwa/crawler.nvim

- 선택한 코드라인의 github url을 생성

  - https://www.reddit.com/r/neovim/comments/1gzid9o/browshernvim_create_commit_pinned_githubgitlab/
  - https://github.com/claydugo/browsher.nvim

- smooth scroll without neovide or kitty + smear cursor
    - from reddit

- jremmen/vim-ripgrep	
```
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

- 전반적으로
  https://patrick-f.tistory.com/36

### 개선서항 [-]

#### 간단

- neovim config debugging 전용
  - util함수에 디버깅용으로 print함수를 덮어씌우는데, 추가할 기능은 만약 목적 대상이 table일 경우 vim.inspect해주는 것이다.

- normal J를 확장: 윗 라인을 아래로, 아래 라인을 위로 sequancial mapping

- render-markdown
  - 'link' 항목 개선하자. 플러그인에서 기본 제공하는 링크 구분(github 등) 외에도 가장 기본 기능인 hyper link 기능을 구분하자.
    내가 앞으로 만드는 문서들은 본문급인 index.md가 있고, 본문에 첨부될 매우 구체적인 노트 조각들도 있다. 이 조각들과 본문을 구분하는건데, 앞의 아이콘을 이용하자.
    구분자로는 `path`가 "1.Project, 2.Area, 3.... "와 같은 문자로 시작되는지 보거나, 파일명이 index.md인지 아닌지만 봐도 좋을 것 같다.
  - 만약 call-out 내에서 입력 중이라면 line change 훅으로 맨 앞에 `>` 기호 자동으로 붙여주기

- `<leader>cc`로 commitmsg 버퍼를 켜면 최종 버퍼의 포키싱 윈도우 범위가 바뀐다.(살짝 올라감)
- auto-session 복구시 탭 이름도 복구 되도록
- keymap: telescope 에서 <C-q>로 선택한 파일을 qf에 추가한다. 근데 이거 곧바로 qflist 버퍼를 띄우기보단 그냥 log만 남겨주는게 좋을듯
- keymap: cmdwindow에서 normal mode <Esc> -> cmdline으로 이동하되, 현재 input내용 그대로 살려서
- 문자 없이 빈 칸에서 `'`키 입력시 message 지우기

- `Tab, S-Tab, g-Tab`으로 버퍼 순회할 때 현재 탭의 윈도우에 active인 것은 제외해도 되겠다. 그리고 이것이 시각적으 로표현되도록 하면 좋겠다.
    [ref](https://www.youtube.com/watch?v=ST_DZ6yIiXY)

- auto-session에서도 telescope로 ui-select

- winbar의 활용

- visual select에서 대문자 S 입력하면 이후 연속해서(sequence) 입력하는 문자에 따라 다양한 기능을 제공한다. 이게 뭔지 알아보자.

- nvim-tree에서 a키로 toggle: git stage / git unstage


#### 복잡

- nvim-tree에서 지금 주황색으로 보여주고 표시하는건 loaded buffer인데, 현재탭의 active window만 보는것도 좋을것같다.    
  정리해보면 not-loaded(기본 트리)/ loaded/ active(cucrent tab) / left(== inactive in current tab)을 한눈에 볼 파악할 수 있는 tree가 있다면 유용하겠다.(ex: avante.nvim selected file에 active 파일들을 모두 추가)

- aerial.nvim에서,

  - treesitter typescript post parse에서 커스텀으로 'type'도 구분하기, 현재는 variable과 동일한 취급
  - function, variable, type의 아이콘을 보다 명확하게 변경하기

- (avante 개선) Predefined Propmts [예시자료](https://github.com/yetone/avante.nvim/wiki/Recipe-and-Tricks)

- 현재 tab에서 loaded / inactive / active 버퍼 리스트를 얻을 수 있는 나만의 utils를 만들어두면 좋겠다. 
  -> scope.nvim

### 버그

- 가끔 색깔이 오락가락 한다. 특히 C-q에 맵핑한 플러그인이 실행될 때 증상이 거의 매번 나타난다. 희안하게도 nvim-tree를 껏다 켜거나, i3로 전체화면 전환해보면 괜찮아진다.
- nvim-tree 외 단 1개의 버퍼만 있을 때 `:bd`로 닫으면, 버퍼가 종료되지 않고 빈 버퍼가 남아버린다.
  현재는 이를 위한 대응을 버퍼 관리 기능들에 덕지덕지 붙여놨다. 이거 좀 개선할 필요가 있겠다.
- 어떤 단위의 첫번째 라인 바로 아래에 코드를 붙여넣으면 refold 되어버린다. [이 사람도 같은 불편을 호소](https://www.reddit.com/r/neovim/comments/1e7tfw2/pasting_line_by_p_makes_refold/)
- harpoon으로 열린 버퍼는 BufReadPost로 실행하고있는 :loadview가 제대로 안된다. cursor_position등 정보를 harpoon이 별도로 저장하고 사용해서 그런듯.

- fugitive 진입 후 윈도우 종료하면 커서 위치가 이상해진다. 마지막 윈도우 커서 위치로 가는게 아니라 가장 왼쪽 윈도우로 이동한다.

### Deprecated

My "aha!" moment came when watching Josean Martinez' video "How to set up linting and formatting"
