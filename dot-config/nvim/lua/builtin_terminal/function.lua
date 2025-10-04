local utils = require("utils")

function OpenOrFocusTerm()
  -- Step 0: 기존에 "Term: "으로 시작하는 이름을 가진 터미널 버퍼가 있다면 아래와 같이 Early Return
  local CB = {} -- current buffer
  CB.number = vim.fn.bufnr()
  CB.name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(CB.number), ":t")
  CB.info = vim.fn.getbufinfo(CB.number)[1]

  if CB.name:find("Term: ") and CB.info.variables and CB.info.variables.terminal_job_id then
    local input = vim.fn.input("Change name: ")
    if input ~= "" then
      vim.api.nvim_buf_set_name(CB.number, "Term: " .. input)
      utils.print_in_time("Changed to: " .. input, 1.5)
    else
      utils.print_in_time("Canceled", 0.5)
    end
    return -- 입력값 없이 입력 또는 ESC를 누른 경우, 함수 종료
  elseif CB.name:find("Term: ") and CB.info.variables and not CB.info.variables.terminal_job_id then
    vim.cmd("term bash")
    vim.cmd("bdelete" .. CB.number) -- :trem은 새로운 버퍼를 생성하므로 기존 버퍼를 삭제한다. 그렇지 않으면 버퍼 이름 중복으로 에러가 발생한다.
    local new_bufnr = vim.fn.bufnr()

    -- vim.schedule을 사용해 이름 설정을 지연하여 터미널 초기화 후 실행
    vim.schedule(function()
      vim.api.nvim_buf_set_name(new_bufnr, CB.name)
      vim.bo[new_bufnr].filetype = "terminal"
      -- vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], {buffer = new_bufnr})
    end)
    return
  end

  -- Step 1: ex 커맨드 라인에서 사용자 입력 요청
  local input = vim.fn.input("Term: ")
  if input == "" then
    -- 입력이 없거나 ESC를 누른 경우, 함수 종료
    return
  end

  -- Step 2: 입력된 이름을 가진 버퍼가 있는지 확인
  local term_name = "Term: " .. input
  local existing_buf = nil

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    -- 버퍼 이름에서 basename만 추출하여 비교
    local buf_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
    if buf_name == term_name then
      existing_buf = bufnr
      break
    end
  end

  if existing_buf then
    -- 이미 동일한 이름을 가진 버퍼가 있을 경우
    local is_visible = false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == existing_buf then
        -- 해당 버퍼가 열려 있는 윈도우로 포커스 이동
        vim.api.nvim_set_current_win(win)
        is_visible = true
        break
      end
    end
    if not is_visible then
      -- 버퍼가 존재하지만, 윈도우에 로드되어 있지 않은 경우 로드
      vim.cmd("buffer " .. existing_buf)
    end
    return -- 이미 열린 버퍼로 이동했으므로 함수 종료
  end

  -- Step 3: 터미널 버퍼 생성 후 이름 설정
  vim.cmd("term")                                   -- 새로운 터미널 버퍼 생성
  local term_bufnr = vim.api.nvim_get_current_buf() -- 새로 생성된 터미널 버퍼 ID 저장

  -- vim.schedule을 사용해 이름 설정을 지연하여 터미널 초기화 후 실행
  vim.schedule(function()
    vim.api.nvim_buf_set_name(term_bufnr, term_name)
    vim.bo[term_bufnr].filetype = "terminal"
    -- vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], {buffer = term_bufnr}) -- TermOpen같은 autocmd 이벤트로 달아버리면 fugitive git push -p 로 생성된 터미널 버퍼에서 불편함을 초래한다.
  end)
end

local function get_c_compile_info()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].modified then
    vim.notify("Please save the file before compiling.", vim.log.levels.WARN)
    return nil
  end
  local relpath = vim.fn.expand("%")
  local filename = vim.fn.expand("%:t")
  local ext = filename:match("^.+(%..+)$")
  if ext ~= ".c" then
    vim.notify("Only .c files are supported", vim.log.levels.ERROR)
    return nil
  end
  -- Replace .c with .out in the relative path
  local outpath = relpath:gsub("%.c$", ".out")
  local compile_cmd = string.format("gcc %s -g -O0 -o %s", relpath, outpath)
  return {
    filepath = relpath,
    filename = filename,
    compile_cmd = compile_cmd,
    exe_path = outpath,
  }
end

function CompileAndRun()
  local info = get_c_compile_info()
  if not info then return end
  local Terminal = require('toggleterm.terminal').Terminal
  local term = Terminal:new({
    direction = "float",
    close_on_exit = false,
    hidden = true,
    cmd = info.compile_cmd .. " && " .. info.exe_path,
    float_opts = {
      border = "solid",
      width = math.floor(vim.o.columns * 0.4),
      col = math.floor(vim.o.columns * 0.5),
      winblend = 50,
    },
  })
  term:toggle()
end

function TypeCompilecommand()
  local info = get_c_compile_info()
  if not info then return end
  local Terminal = require('toggleterm.terminal').Terminal
  local term = Terminal:new({
    direction = "float",
    close_on_exit = true,
    hidden = true,
    float_opts = {
      border = "solid",
      width = math.floor(vim.o.columns * 0.3),
      height = math.floor(vim.o.lines * 0.2),
      winblend = 50,
    },
  })
  term:toggle()
  term:send(info.compile_cmd, false)
end
