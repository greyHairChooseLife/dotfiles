local utils = require("utils")

function NavBuffAfterCleaning(direction)
  utils.close_empty_unnamed_buffers()
  vim.cmd(direction == "prev" and "bprev" or "bnext")

  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname:find("Term: ") then
    vim.cmd(direction == "prev" and "bprev" or "bnext")
  end

  local listed_buffers = vim.fn.getbufinfo({ buflisted = 1 })
  -- "Term: "으로 시작하는 버퍼를 제거
  local filtered_buffers = vim.tbl_filter(function(buf)
    return not string.find(buf.name, "Term:")
  end, listed_buffers)

  local current_bufnr = vim.fn.bufnr()
  local current_buf_index

  for i, buf in ipairs(filtered_buffers) do
    if buf.bufnr == current_bufnr then
      current_buf_index = i
      break
    end
  end

  utils.print_in_time("  Buffers .. [" .. current_buf_index .. "/" .. #filtered_buffers .. "]", 2)
end

function NavBuffAfterCleaningExceptCurrentTabShowing(direction)
  local initial_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()
  local attempts = 0
  local max_attempts = 20

  repeat
    NavBuffAfterCleaning(direction)
    local current_buf = vim.api.nvim_get_current_buf()
    attempts = attempts + 1

    -- Check if this buffer is visible in OTHER windows (not current window)
    local is_visible_elsewhere = false
    for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if win_id ~= current_win and vim.api.nvim_win_get_buf(win_id) == current_buf then
        is_visible_elsewhere = true
        break
      end
    end

    if attempts >= max_attempts or current_buf == initial_buf then
      break
    end
  until not is_visible_elsewhere
end

function BufferNextDropLast()
  -- DEPRECATED:: 2025-06-07
  -- local last_buf = vim.api.nvim_get_current_buf()
  -- local listed_buffers = vim.fn.getbufinfo({ buflisted = 1 })
  -- -- "Term: "으로 시작하는 버퍼를 제거
  -- local filtered_buffers = vim.tbl_filter(function(buf)
  -- 	return not string.find(buf.name, "Term:")
  -- end, listed_buffers)
  -- -- hidden 버퍼만 필터링
  -- local hidden_bufs = {}
  -- for _, buf in ipairs(filtered_buffers) do
  -- 	if buf.hidden == 1 then
  -- 		table.insert(hidden_bufs, buf.bufnr)
  -- 	end
  -- end
  -- -- 테이블에 요소가 1개 이상이라면, 다음 버퍼로 0번째 버퍼로 이동
  -- if #hidden_bufs > 0 then
  -- 	vim.api.nvim_set_current_buf(hidden_bufs[1])
  -- end
  -- -- 어쨋든 최근 버퍼는 닫는다.
  -- vim.cmd("bd " .. last_buf)

  local last_buf = vim.api.nvim_get_current_buf()

  NavBuffAfterCleaningExceptCurrentTabShowing("next")

  -- Close the original buffer after navigating
  if vim.api.nvim_buf_is_valid(last_buf) then
    if last_buf == vim.api.nvim_get_current_buf() then
      vim.fn.feedkeys("gq")
    else
      vim.cmd("bd " .. last_buf)
    end
  end
end

function CloseOtherBuffersInCurrentTab()
  local current_buf_id = vim.api.nvim_get_current_buf()
  local current_win_id = vim.api.nvim_get_current_win()
  local current_tab_id = vim.api.nvim_get_current_tabpage()
  local window_ids = vim.api.nvim_tabpage_list_wins(current_tab_id)

  local excluded_buftypes = { "nofile" }

  for _, win_id in ipairs(window_ids) do
    if not vim.api.nvim_win_is_valid(win_id) then
      goto continue
    end

    local buf_id = vim.api.nvim_win_get_buf(win_id)
    if win_id ~= current_win_id and buf_id ~= current_buf_id then
      if
          utils.is_buffer_shown_only_in_current_tab(buf_id)
          and not vim.tbl_contains(excluded_buftypes, vim.bo[buf_id].buftype)
      then
        vim.api.nvim_buf_delete(buf_id, { force = true })
      else
        ManageBuffer_gq(nil, win_id)
      end
    end

    ::continue::
  end

  vim.cmd("only")
end

function TabOnlyAndCloseHiddenBuffers()
  vim.cmd("TTimerlyClose")
  -- 현재 탭에서 열린 버퍼 번호들을 저장
  local open_buffers = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    open_buffers[buf] = true
  end

  -- 모든 버퍼를 순회하며, 열린 버퍼에 포함되지 않은(hidden 상태인) 버퍼를 닫기
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if not open_buffers[buf] and vim.api.nvim_buf_is_loaded(buf) then
      local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
      if filetype ~= "VoltWindow" then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end

  print("tab only, wipe invisible buffers")
  vim.cmd("silent tabonly")
end

function ManageBuffer_ge()
  vim.cmd("w") -- 일단 저장
  ManageBuffer_gq()
  vim.notify("Saved last buffers", 2, { render = "minimal" })
end

local function close_if_last_with_nvimtree()
  local all_windows = vim.api.nvim_list_wins()

  if #all_windows == 2 then
    local current_win = vim.api.nvim_get_current_win()
    local other_win

    -- Find the window that isn't the current one
    for _, win in ipairs(all_windows) do
      if win ~= current_win then
        other_win = win
        break
      end
    end

    -- Check if the other window is NvimTree
    if other_win then
      local buf = vim.api.nvim_win_get_buf(other_win)
      if vim.bo[buf].filetype == "NvimTree" then
        vim.cmd("q")
      end
    end
  end
end

---@param bufnr integer?
---@param winid integer?
function ManageBuffer_gq(bufnr, winid)
  bufnr = bufnr or (winid and vim.api.nvim_win_get_buf(winid)) or vim.fn.bufnr("%")

  -- Early return if buffer is not valid
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return vim.notify(bufnr .. " is not valid bufrn.", 3, { render = "minimal" })
  end

  local excluded_filetypes = { "help", "gitcommit", "NvimTree", "codecompanion" }
  local excluded_buftypes = { "nofile" }

  local is_buflisted = vim.bo[bufnr].buflisted
  local bufname_empty = vim.fn.bufname(bufnr) == ""
  local buffer_active_in_other_window = utils.is_buffer_active_somewhere(bufnr)
  local excluded_filetype = vim.tbl_contains(excluded_filetypes, vim.bo[bufnr].filetype)
  local excluded_buftype = vim.tbl_contains(excluded_buftypes, vim.bo[bufnr].buftype)

  -- 모든 조건을 통과해야만 버퍼를 메모리에서 삭제
  if
      is_buflisted
      and not bufname_empty
      and not buffer_active_in_other_window
      and not excluded_filetype
      and not excluded_buftype
  then
    if #vim.api.nvim_list_wins() == 1 then
      return vim.cmd("q")
    end
    close_if_last_with_nvimtree()
    vim.cmd.bdelete(bufnr)
    print("quit: 1")
  else
    if utils.is_last_window() then
      vim.cmd("q")
      print("quit: 2")
    else
      vim.api.nvim_win_close(winid or 0, false) -- win_id가 주어지지 않으면 그냥 현재 윈도우
      print("quit: 3")
    end
  end
end

function ManageBuffer_gtq()
  -- NvimTree는 꼭 이렇게 별도로 꺼줘야한다.
  if require("nvim-tree.api").tree.is_visible() then
    vim.cmd("NvimTreeClose")
  end

  -- 예외처리: 특수 탭
  local special_tabs = { " Commit", " File", "GV", "Diff" }
  local tabname = utils.get_current_tabname()
  local is_special_tabs = vim.tbl_contains(special_tabs, tabname)
  if is_special_tabs then
    return vim.cmd("tabclose!")
  end

  local wins = vim.api.nvim_tabpage_list_wins(0)
  for _, win in ipairs(wins) do
    if vim.api.nvim_win_is_valid(win) then
      local bufnr = vim.api.nvim_win_get_buf(win)
      ManageBuffer_gq(bufnr)
    end
  end
end

function ManageBuffer_gQ() -- loaded buffer를 모두 닫는다.
  local bufnr = vim.fn.bufnr("%")

  vim.cmd("q")

  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true }) -- bwipeout
  end
end

function ManageBuffer_gE() -- 저장 후, loaded buffer를 모두 닫는다.
  vim.cmd("w")

  ManageBuffer_gQ()
  vim.notify("Saved last buffers", 2, { render = "minimal" })
end

function ManageBuffer_gtQ()
  vim.notify("그간의 경험을 돌아보면 딱히 쓴 일, 쓸 일이 없는데?", 1, { render = "minimal" })
end

function FocusFloatingWindow()
  local wins = vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    local config = vim.api.nvim_win_get_config(win)
    if config.focusable and config.relative ~= "" then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end

function NewTabWithPrompt()
  local on_confirm = function(value)
    if not value or value == "" then
      return
    else
      vim.cmd("tabnew")
      local tabnr = vim.fn.tabpagenr()
      vim.fn.settabvar(tabnr, "tabname", value)
    end
  end

  Snacks.input.input({
    icon = "",
    prompt = "new tab",
    default = current_tabname,
    win = {
      style = {
        row = vim.api.nvim_win_get_height(0) / 2 - 3,
      },
    },
  }, on_confirm)
end

function RenameCurrentTab()
  local current_tabname = vim.t[0].tabname
  if current_tabname == nil or current_tabname == vim.NIL then
    current_tabname = ""
  end

  local prev_tab_ui_length = function(cur_tabnr)
    local tab_ui_minimum_length = 15 -- File Path: lua/UI/tabline.lua, 211:211
    local tab_ui_maximum_length = 45 -- File Path: lua/UI/tabline.lua, 211:211
    if cur_tabnr <= 1 then
      return 0
    end

    local prev_tabname = vim.t[utils.get_tab_id_from_order(cur_tabnr - 1)].tabname
    if prev_tabname == nil or prev_tabname == vim.NIL then
      prev_tabname = ""
    end
    if #prev_tabname > tab_ui_minimum_length then
      if #prev_tabname < tab_ui_maximum_length then
        return #prev_tabname + 6
      else
        return tab_ui_maximum_length + 6
      end
    else
      return tab_ui_minimum_length + 3
    end
  end

  local function accumulated_prev_tabs_length(cur_tabnr)
    local total_length = 0
    for i = 2, cur_tabnr do
      total_length = total_length + prev_tab_ui_length(i)
    end
    return total_length
  end

  local tabnr = vim.fn.tabpagenr()
  local col = accumulated_prev_tabs_length(tabnr)

  local on_confirm = function(value)
    if not value or value == "" then
      return
    else
      vim.fn.settabvar(tabnr, "tabname", value)
      vim.cmd("redrawtabline")
    end
  end

  Snacks.input.input({
    icon = "",
    prompt = "rename",
    default = current_tabname,
    win = {
      style = {
        width = 40,
        title_pos = "left",
        row = 1,
        col = col,
      },
    },
  }, on_confirm)
end

function MoveTabLeft()
  local current_tab = vim.fn.tabpagenr()
  if current_tab == 1 then
    vim.cmd("tabmove $")
  elseif current_tab > 1 then
    vim.cmd("tabmove " .. (current_tab - 2))
  end
end

function MoveTabRight()
  local current_tab = vim.fn.tabpagenr()
  local total_tabs = vim.fn.tabpagenr("$")
  if current_tab < total_tabs then
    vim.cmd("tabmove " .. current_tab + 1)
  else
    vim.cmd("tabmove 0")
  end
end

function SplitTabModifyTabname()
  vim.cmd("split | wincmd T")
  local tabnr = vim.fn.tabpagenr()
  local filename = vim.fn.expand("%:t")
  if filename ~= "" then
    vim.fn.settabvar(tabnr, "tabname", " sp: " .. filename)
  end
end

function MoveTabModifyTabname()
  vim.cmd("wincmd T")
  local tabnr = vim.fn.tabpagenr()
  local filename = vim.fn.expand("%:t")
  if filename ~= "" then
    vim.fn.settabvar(tabnr, "tabname", " mv: " .. filename)
  end
end

---@class FloatWindowOpts
---@field filepath string? File path to open in the window
---@field content string[]? Content to display (string or table of lines)
---@field width number? Window width (default: 90% of screen)
---@field height number? Window height (default: 80% of screen)
---@field col number? Window X position (default: centered)
---@field row number? Window Y position (default: centered)
---@field relative string? Position reference ('editor'|'win'|'cursor', default: 'editor')
---@field style string? Window style (default: 'minimal')
---@field border string? Border style (default: 'rounded')
--- 플로팅 윈도우를 생성하는 함수
---@param opts FloatWindowOpts? 플로팅 윈도우 생성 옵션
---@return number win 생성된 윈도우의 ID
---@return number buf 생성된 버퍼의 ID
function OpenFloatWindow(opts)
  opts = opts or {}

  -- 버퍼 생성
  local buf = vim.api.nvim_create_buf(false, true)

  -- 입력 소스 처리
  if opts.filepath then
    -- Check if the file is already open in another buffer
    local existing_bufnr = -1
    for _, bufid in ipairs(vim.api.nvim_list_bufs()) do
      local bufname = vim.api.nvim_buf_get_name(bufid)
      if bufname == opts.filepath then
        existing_bufnr = bufid
        break
      end
    end

    if existing_bufnr ~= -1 then
      -- Use existing buffer's content instead of creating a new one
      vim.api.nvim_buf_delete(buf, { force = true })
      buf = existing_bufnr
    else
      -- Read the file content without affecting the current buffer
      local lines = {}
      local file = io.open(opts.filepath, "r")
      if file then
        for line in file:lines() do
          table.insert(lines, line)
        end
        file:close()
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)

        -- Set the buffer's name/path but don't change nvim-tree's buffer
        -- Use pcall to handle potential errors when setting buffer name
        pcall(vim.api.nvim_buf_set_name, buf, opts.filepath)

        -- Make the buffer a proper file buffer
        vim.bo[buf].buftype = ""
        vim.bo[buf].modifiable = true

        -- Set filetype based on file extension
        local filetype = vim.filetype.match({ filename = opts.filepath })
        if filetype then
          vim.bo[buf].filetype = filetype
        end
      else
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "Could not open file: " .. opts.filepath })
      end
    end
  elseif opts.content then
    -- 내용 직접 설정
    local lines = type(opts.content) == "table" and opts.content or { opts.content }
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  else
    -- 기본 내용
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "Empty floating window" })
  end

  -- 윈도우 크기 계산 (기본값: 너비 90%, 높이 80%)
  local width = opts.width or math.floor(vim.o.columns * 0.7)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  -- 중앙 정렬을 위한 위치 계산
  -- local col = opts.col or math.floor((vim.o.columns - width) / 2)
  local col = opts.col or 45
  local row = opts.row or math.floor((vim.o.lines - height) / 4)

  -- 윈도우 옵션
  local win_opts = {
    relative = opts.relative or "editor", -- 'editor', 'win', 'cursor'
    width = width,
    height = height,
    col = col,
    row = row,
    style = opts.style or "minimal",
    border = opts.border or "single",
  }

  -- 윈도우 열기 & 옵션 세팅
  local win = vim.api.nvim_open_win(buf, true, win_opts)
  local setOpt = utils.setOpt
  setOpt("winhighlight", "Normal:Normal,EndOfBuffer:EndOfBuffer")
  setOpt("number", true)
  setOpt("relativenumber", true)
  setOpt("signcolumn", "no")

  return win, buf
end

function Close_all_hidden_buffers()
  local listed_buffers = vim.fn.getbufinfo({ buflisted = 1 })
  local visible_buffers = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    visible_buffers[buf] = true
  end

  for _, bufinfo in ipairs(listed_buffers) do
    local buf = bufinfo.bufnr
    if not visible_buffers[buf] then
      vim.api.nvim_buf_delete(buf, {})
    end
  end
end
