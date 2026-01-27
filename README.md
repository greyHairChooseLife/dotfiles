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

### TODO

- tmux resurrection 이거 내가 원하는 시점으로 이동하고, 필요시 스냅샷을 제거할 수 있도록

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



## NVIM

### etc

- > workspace generator
  >
  > - make another part for generating workspace group that brings everything.
  > - make on_palette prompt for listing worksapce of all data and update README.md to structure subdivided todo list based on specs/*.
  >   _"Based on the specifications, make README.md. And append step by step todo-list in the README.md for developing application using @full_stack_dev"_

- render markdown todo list 관련 재조정
  - callout에 todo도 개선
  - 기존 스티커 형태로 사용하는건 안먹힌다.
  - cancel, done, todo 등으로 전환하는 키맵도 있어야겠다.


- nvimtree 에서 필터링 따위를 통해 현재 텝에서 열린것/숨겨진 것 등만 표시하는 기능 



- lualine의 inactive에서 a_파트를 고정 색이 아니라 만약 현재 탭에 동일한 버퍼가 active인 경우에 똑같이 오렌지색으로 넣어주자.


- 텝 생성시 esc로 취소하면 자꾸 그냥 만들어진다. no name으로. 이거 /,? search 기능에서 esc 뚫어낸거랑 같은 방식으로 할 수 있을듯?


- winbar의 활용

- visual select에서 대문자 S 입력하면 이후 연속해서(sequence) 입력하는 문자에 따라 다양한 기능을 제공한다. 이게 뭔지 알아보자.

- (config 훔치기) https://patrick-f.tistory.com/36

- 레딧 saved-list 확인

- search 'best picker' on reddit

- utils는 각 workflow마다의 util이 있고, global util이 있겠다. 이를
  구분하자. 이때 기존 workflow의 function.lua가 util이 되면 적절하겠다. 독립적
  기능은 modules로 이동하자.

- nvimtree에 포커싱 되어있을 때 커서라인 색상 주황색 또는 연두색으로


- revive buffer 이거 delete된 버퍼만 살아온다. 그냥 quit은 아님. qg로 되살리도록 하자. 걍 quit이든 bdelete이든 상관 없을 무

  ```
  -- Lua
  local last_closed_window = nil

  -- 윈도우가 닫힐 때 상태를 저장
  vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(args)
      local win_id = tonumber(args.match) -- 닫힌 윈도우 ID
      if vim.api.nvim_win_is_valid(win_id) then
        local buf_id = vim.api.nvim_win_get_buf(win_id)
        local pos = vim.api.nvim_win_get_position(win_id)
        local width = vim.api.nvim_win_get_width(win_id)
        local height = vim.api.nvim_win_get_height(win_id)
        last_closed_window = {
          buf_id = buf_id,
          pos = pos,
          width = width,
          height = height,
        }
      end
    end,
  })

  -- 마지막으로 닫힌 윈도우를 복원
  local function reopen_last_closed_window()
    if last_closed_window and vim.api.nvim_buf_is_valid(last_closed_window.buf_id) then
      -- 새 윈도우 열기
      vim.cmd("vsplit")
      local new_win = vim.api.nvim_get_current_win()

      -- 버퍼 설정
      vim.api.nvim_win_set_buf(new_win, last_closed_window.buf_id)

      -- 크기 및 위치 복원
      vim.api.nvim_win_set_width(new_win, last_closed_window.width)
      vim.api.nvim_win_set_height(new_win, last_closed_window.height)

      print("Last closed window restored.")
    else
      print("No valid window to restore.")
    end
  end

  -- 명령어로 등록
  vim.api.nvim_create_user_command("ReopenLastWindow", reopen_last_closed_window, {})
  ```

- <leader>s로 검색하는 기능의 확장으로,
  papago api따위를 활용하여 번역 후 결과를 작은 floating window로 띄우기

### codecompanion


- ~채팅에 이름 달아주고, picker에서 해당 채팅을 열기~
- ~dump, restore, delete 기능을 키맵으로 만들자: <leader>s로 세션 기능 내에 달아주면 될듯~

- 현재까지의 대화내용을 바탕으로 나의 영어 작문 능력을 개선하기 위해 `as-is > to-be` 형태로 요약/튜터링 해 주기. 더 자연스러운 표현으로!
  - 이거 hook 달아서 채팅 꺼질 때 마다 llm이 내 영어 작문 오답노트를 생성해주게 해도 좋을듯?

- /workspace with vectorcode plugin [ref](https://codecompanion.olimorris.dev/extending/workspace.html)

- mcp!


### 관심있는 플러그인



- 원하는 대로 리스트를 담은 메뉴를 만들 수 있다. 말하자면, vim.ui.select의 Wrapper
  https://github.com/leath-dub/snipe.nvim

- [snacks.scope](https://github.com/folke/snacks.nvim/blob/main/docs/scope.md)
  : 조건문, 반복문 등도 treesitter에 등록시켜주나? 그래서 aerial에서도 확인 할 수 있나?

- new plugin: [gitgraph](https://github.com/isakbm/gitgraph.nvim)


- http client inside neovim

  - https://github.com/rest-nvim/rest.nvim
  - https://www.reddit.com/r/neovim/comments/1eh0yr6/restnvim_is_back/
  - https://github.com/mistweaverco/kulala.nvim



- crawling web pages, rendering them to Markdown or JSON, and inserting the content into new buffers. It also supports asynchronous search functionality.

  - https://github.com/twilwa/crawler.nvim

- 선택한 코드라인의 github url을 생성

  - https://www.reddit.com/r/neovim/comments/1gzid9o/browshernvim_create_commit_pinned_githubgitlab/
  - https://github.com/claydugo/browsher.nvim


