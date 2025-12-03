

```
   Error  11:11:53 AM msg_show.emsg

E5108: Error executing lua: /home/sy/.config/nvim/lua/buf_win_tab/function.lua:210: User Autocommands for "GitSignsUpdate": Vim(append):Error executing lua callback: .../nvim/lazy/nvim-tree.lua/lua/nvim-tree/renderer/init.lua:46: E565: Not allowed to change text or change window
stack traceback:
	[C]: in function 'nvim_buf_set_lines'
	.../nvim/lazy/nvim-tree.lua/lua/nvim-tree/renderer/init.lua:46: in function '_draw'
	.../nvim/lazy/nvim-tree.lua/lua/nvim-tree/renderer/init.lua:110: in function 'draw'
	.../nvim/lazy/nvim-tree.lua/lua/nvim-tree/explorer/init.lua:490: in function 'reload'
	/home/sy/.config/nvim/lua/git_diff/plugins/gitsigns.lua:46: in function </home/sy/.config/nvim/lua/git_diff/plugins/gitsigns.lua:45>
	[C]: in function 'nvim_exec_autocmds'
	...al/share/nvim/lazy/gitsigns.nvim/lua/gitsigns/status.lua:15: in function 'autocmd_update'
	...al/share/nvim/lazy/gitsigns.nvim/lua/gitsigns/status.lua:49: in function 'clear'
	...al/share/nvim/lazy/gitsigns.nvim/lua/gitsigns/attach.lua:430: in function 'detach'
	...al/share/nvim/lazy/gitsigns.nvim/lua/gitsigns/attach.lua:74: in function <...al/share/nvim/lazy/gitsigns.nvim/lua/gitsigns/attach.lua:72>
	[C]: in function 'bdelete'
	/home/sy/.config/nvim/lua/buf_win_tab/function.lua:210: in function </home/sy/.config/nvim/lua/buf_win_tab/function.lua:180>
stack traceback:
	[C]: in function 'bdelete'
	/home/sy/.config/nvim/lua/buf_win_tab/function.lua:210: in function </home/sy/.config/nvim/lua/buf_win_tab/function.lua:180>
```




**fugitive**

- staged/unstaged 목록에서 i누르면 변경내역이 보이듯이, not-pushed list에서도 i누르면 변경 파일이 보이도록 해보자.

  1. 변경된 파일 목록 (상대경로)
  2. 커밋 메시지
  3. 변경된 파일 목록별 변경량 add/remove/change






**neovim.picker**

- ignored file search
  - [ ] 내 find file 명령어(Ctrl+k)에 맵핑된것도 ignored파일 볼 수 있는 방식으로 전환 가능하게




**auto-session**

- 지금은 현재 cwd에 저장이 되는데, 이걸 임의 지정할 수 있으면 좋겠다. ui_input에서 현재 cwd를 default로 가지고, 내가 확인하는 식
- 동일 기준점(cwd 등)에 대하여 다수의 named session이 필요할 수 있겠다.





**window layout & size**

- 현재는 각 window 마다 fix할 수 있는 방식이다.
- 근데 마치 사진을 찍듯이 찍어놔도 좋겠다. 이때 기본 기능을 활용해 fix하기보다,
    그냥 윈도우별 사이즈를 런타임 메모리에 저장하고,
      이후 필요시 그것을 가져오는 방식이면 좋을듯??








**buffer**

- 방금 종료한 버퍼 부활시키는거 제대로 안된다. 자꾸 딴놈이 켜지고 꺼짐;

- 분명 버퍼가 완전히 종료되어야하는데 끈질기게 살아있는 애들이 있다.

- 현재 탭의 윈도우에 중복으로 켜져있는(복수의 윈도우에 보여지는) 버퍼들을 모두 정리하여 하나씩만 켜져있도록 하는 기능



**codecompanion**

- AI가 나를 무능하게 만들지 않도록 하기위한 방법으로,

  - _AS IS_
    1. 계획(AI에 요청 후 내가 검토)
    2. 구현(**AI에 요청 후 내가 검토**)

  - _TO BE_
    1. 계획(AI에 요청 후 내가 검토)
    2. 구현(**내가 만든 뒤 AI에 검토 요청**)

  이를 손쉽게 하기 위해서는 커밋을 잘 활용해야하며, commit 또는 status를 잘 제공하는 방법을 알고 또 세팅해둬야겠다.


- global metadata를 제공한다. 토큰 사용량이나 모델 등... 이전에는 내부로 깊게 파고들어서 얻어내어 ui에 활용했는데 이부분을 보다 일반적으로 개선할 수 있겠다.
   
  > [!rf]
  > **f962b2e feat(chat): add global metadata (#1973)**
  >
  > CodeCompanion exposes a global dictionary,
  > `_G.codecompanion_chat_metadata` which users can leverage throughout
  > their configuration. Using the chat buffer's buffer number as the key, the
  > dictionary contains:
  > 
  > - `adapter` - The `name` and `model` of the chat buffer's current adapter
  > - `context_items` - The number of context items current in the chat buffer
  > - `cycles` - The number of cycles (User->LLM->User) that have taken place in the chat buffer
  > - `id` - The ID of the chat buffer
  > - `tokens` - The running total of tokens for the chat buffer
  > - `tools` - The number of tools in the chat buffer






**LSP**

- 이놈이 먹는 메모리가 상당하다. 어떻게 관리해야할까?
  - 특히 세션을 관리할 때 문제가 된다. 동일 경로에 세션은 하나뿐이니, 그냥 켜두는 방식으로 하는데, 이러면 lsp 서버가 시스템 메모리를 상당히 먹는다.
  - 에디터가 포커스를 완전히 잃게 될 때마다 lsp서버를 중단? LspStop은 시도해봐도 별 소득이 없다.



**gitsign**

- gpr로 prev 볼 때, hunk단위가 이상하다. cn, cp로 hunk를 이동할땐 +/-/~ 모두 연속되면 한 덩어리로 보는데, prev 볼 땐 이걸 또 다 나눠놓는다. 한덩어리로 보여야 한다.





**lualine**
- lualine의 inactive에서 a_파트를 고정 색이 아니라 만약 현재 탭에 동일한 버퍼가 active인 경우에 똑같이 오렌지색으로 넣어주자.




**render markdown**
- render markdown todo list 관련 재조정
  - callout에 todo도 개선
  - 기존 스티커 형태로 사용하는건 안먹힌다.
  - cancel, done, todo 등으로 전환하는 키맵도 있어야겠다.


https://www.youtube.com/watch?v=KMgnFDaIhBs
https://www.youtube.com/watch?v=xgbjLq_R52o
https://www.youtube.com/watch?v=Rwnr5UjV2FY
http://www.kocw.net/home/search/kemView.do?kemId=1046323



## new plugin

[Hex.nvim](https://github.com/RaafatTurki/hex.nvim)
[tiny-code-action.nvim](https://github.com/rachartier/tiny-code-action.nvim)

[touch fugitive](https://github.com/justinmk/vim-ug)




## lualine


M.colors = {
    normalBG = "#24283b", -- normal bg color
    -- git
    gitAdd = "#40cd52",
    gitChange = "#ffcc00",
    gitDelete = "#f1502f",
    -- colors
    black1 = "#000000",
    black2 = "#282c34",
    black3 = "#333342",
    black4 = "#8b8378",
    black5 = "#abb2bf",
    white1 = "#ffffff",
    blue1 = "#0020fc",
    blue2 = "#61afef",
    green1 = "#98c379",
    orange1 = "#FF8C00",
    orange2 = "#cd853f",
    purple1 = "#A020F0",
    purple2 = "#c678dd",
    red1 = "#DC143C",
    yellow1 = "#ffff00",
    -- plugin specific
    warpBG = "#f1502f",
    termBG = "#0c0c0c",
    noteBG = "#242024", -- note bg color
    qfBG = "#201010",
    qfFG = "#db4b4b",
    nvimtreeBG = "#333342",
    oilBG = "#1A1601",
    oilFG = "#BDB80B",
}


- File Path: lua/qol/option.lua, 22:39
  ```lua
  opt.fillchars = {
      vert = "┃", -- 수직 창 구분선
      fold = "·", -- 접힌 텍스트 표시
      foldopen = "▾", -- 펼쳐진 fold 표시
      foldsep = "│", -- fold 열 구분선
      foldclose = "▸", -- 접힌 fold 표시
      -- diff = "", -- diff 모드 삭제된 라인
      eob = " ", -- 버퍼 끝의 빈 라인 (~) 대체
      horiz = "━", -- 수평 창 구분선
      horizup = "┻", -- 수평-수직 교차점
      horizdown = "┳", -- 수평-수직 교차점
      vertleft = "┫", -- 수직-수평 교차점
      vertright = "┣", -- 수직-수평 교차점
      -- https://www.reddit.com/r/neovim/comments/1dlrgnd/how_to_achieve_this_in_lualinenvim/
      -- status line
      stl = "─",
      stlnc = "─",
  }
  ```
