-- MEMO:: 이벤트 종류는 doc에서 아래를 검색하면 나온다.
-- 5. Events					*autocmd-events* *E215* *E216*

local utils = require("utils")

-- Autocommand 그룹 생성 (중복 방지)
local float_win_group = vim.api.nvim_create_augroup("FloatWinSettings", { clear = true })

-- WinEnter 이벤트에 대한 Autocommand 생성
vim.api.nvim_create_autocmd("WinEnter", {
    group = float_win_group,
    callback = function()
        if vim.bo.buftype == "" or vim.bo.buftype == "help" then vim.wo.cursorline = false end
        local win = vim.api.nvim_get_current_win()
        local config = vim.api.nvim_win_get_config(win)

        -- 플로팅 윈도우는 'relative' 필드가 비어있지 않음
        if config.relative ~= "" then
            -- focus.nvim은 편집 중인 버퍼를 그대로 플로팅 윈도우에 표시하므로,
            -- buffer-local gq 키맵을 설정하면 Focus 종료 후에도 남아서 gq가 오동작함
            local is_focus = pcall(require, "focus") and require("focus.views.focus").is_open() and require("focus.views.focus").win == win
            -- 플로팅 윈도우에만 적용할 키맵 설정 (focus.nvim 윈도우 제외)
            if vim.bo.filetype ~= "VoltWindow" and not is_focus then vim.keymap.set({ "n", "v" }, "gq", "<cmd>quit<CR>", { buffer = true, silent = true }) end
        else
            -- 플로팅 윈도우가 아닌 윈도우에 진입할 때, buffer-local gq 키맵이 남아있으면 제거
            pcall(vim.keymap.del, { "n", "v" }, "gq", { buffer = true })
        end
    end,
})

vim.api.nvim_create_autocmd("WinLeave", {
    callback = function()
        if vim.bo.buftype == "" or vim.bo.buftype == "help" then vim.wo.cursorline = true end
    end,
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
    callback = function()
        if vim.bo.buftype == "" or vim.bo.buftype == "help" then vim.wo.cursorline = false end

        -- reviving session breaks NvimTree buffer sometimes
        if vim.bo.filetype == "NvimTree" then
            local api = require("nvim-tree.api")
            local view = require("nvim-tree.view")

            -- gui
            if not view.is_visible() then api.tree.open() end
        end

        -- hide cursor for some filetypes
        local ft_for_hiding_cursor = { "aerial", "NvimTree", "DiffviewFiles", "DiffviewFileHistory" }
        if vim.tbl_contains(ft_for_hiding_cursor, vim.bo.filetype) then utils.cursor.hide() end
    end,
})

vim.api.nvim_create_autocmd("TabNew", {
    callback = function()
        -- tabname이 커스텀 되는 것도 시간이 걸리기 떄문에, 약간의 딜레이를 줘야한다.
        vim.defer_fn(function()
            local tabname = utils.get_current_tabname()
            if tabname == " Commit" or tabname == " File" then vim.cmd("IBLDisable") end
        end, 50)
    end,
})

vim.api.nvim_create_autocmd("TabEnter", {
    callback = function()
        require("nvim-tree.api").tree.reload() -- open된 buffer를 찾는 부분이 업데이트가 늦다. 탭 옮길때 갱신하면 잘 됨.
        local tabname = utils.get_current_tabname()
        if tabname == " Commit" or tabname == " File" then vim.cmd("IBLDisable") end
    end,
})

vim.api.nvim_create_autocmd("TabLeave", {
    callback = function()
        local tabname = utils.get_current_tabname()
        if tabname == " Commit" or tabname == " File" then vim.cmd("IBLEnable") end
    end,
})

vim.api.nvim_create_autocmd("TabClosed", {
    callback = function()
        -- DEPRECATED:: 2025-04-22
        -- 없는게 자연스런 순서
        -- vim.cmd("tabprev")
    end,
})

-- MEMO:: Fold view 자동 저장
vim.api.nvim_create_autocmd("BufWinLeave", {
    pattern = "*",
    callback = function()
        if vim.bo.buftype == "" then vim.cmd("silent! mkview") end
    end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*",
    callback = function()
        vim.cmd("normal! zR")
        vim.cmd("silent! loadview")

        -- 마지막 커서 위치로 이동
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        if mark[1] > 0 and mark[1] <= vim.fn.line("$") then vim.api.nvim_win_set_cursor(0, mark) end
    end,
})

-- highlight yanked area
vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function() vim.highlight.on_yank({ higroup = "Visual", timeout = 100 }) end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
        -- 예외 규정
        if vim.bo.filetype ~= "markdown" and vim.bo.filetype ~= "vimwiki" then
            RemoveTrailingWhitespace() -- 파일 저장시 공백 제거
        end

        require("utils").auto_mkdir()
    end,
})

vim.api.nvim_create_autocmd("CmdlineEnter", {
    callback = function()
        -- -- 명령줄 입력 시에만 활성화
        -- GUI
        -- vim.opt.cmdheight = 1
        utils.cursor.show()

        -- KEYMAP
        vim.api.nvim_set_keymap("c", "<Esc>", [[<C-u><Cmd>lua vim.fn.histdel("cmd", 0)<CR><Esc><Cmd>echon<CR>]], { noremap = true, silent = true }) -- 실행하지 않은 명령은 cmd history에 기록 안됨
    end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function()
        -- -- 명령줄 입력 시에만 활성화
        -- GUI
        -- vim.opt.cmdheight = 0
        vim.schedule(function()
            -- 이 시점에서는 일반 모드로 전환이 완료되어 버퍼/윈도우 관련 API를 안전하게 사용할 수 있음
            if vim.bo.filetype == "NvimTree" then utils.cursor.hide() end
        end)
    end,
})

vim.api.nvim_create_autocmd("CmdwinEnter", {
    callback = function()
        vim.api.nvim_set_hl(0, "CmdlineWindowBG", { bg = "#0d0d0d" })
        vim.api.nvim_set_hl(0, "CmdlineWindowFG", { fg = "#0d0d0d" })
        vim.wo.winhighlight = "Normal:CmdlineWindowBG,EndOfBuffer:CmdlineWindowFG,SignColumn:CmdlineWindowBG"
        vim.wo.relativenumber = false
        vim.wo.number = false
        vim.o.laststatus = 0
        vim.o.cmdheight = 0

        vim.cmd("resize 20 | normal zb")

        -- KEYMAP
        local map = vim.keymap.set
        local opts = { buffer = true }
        map("n", "gq", "<Cmd>q<CR>", opts)
        map("n", "gw", UpdateCommandWindowHistory, opts)
        map("n", "ge", function()
            UpdateCommandWindowHistory()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", true)
        end, opts)

        map("i", "gq", "<Cmd>stopinsert!<CR>", opts)
        map("i", ";j<Space>", "<Cmd>stopinsert!<CR>", opts)
    end,
})

vim.api.nvim_create_autocmd("CmdwinLeave", {
    callback = function()
        -- vim.api.nvim_del_augroup_by_name("CmdwinEnter_GUI_KEYMAP")
        vim.o.laststatus = 2
    end,
})

-- 숫자 global marks (0~9) 자동 삭제: shada에서 로드된 후 지움
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function() pcall(vim.cmd, "delmarks 0123456789") end,
})

-- TODO: 이거 왜 설정한거지? 찾아서 정리 해두기
-- REMOVE KEYMAP FROM NO-WHERE
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        pcall(vim.keymap.del, "i", "<C-G>s")
        pcall(vim.keymap.del, "i", "<C-G>S")
        vim.cmd("clearjumps") -- neovim 시작 시 jumplist 초기화
    end,
})

-- Make <Esc> behave like <C-c> when in search command line mode
vim.api.nvim_create_augroup("SearchKeySwap", { clear = true })

vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = "SearchKeySwap",
    pattern = "/",
    callback = function() vim.api.nvim_buf_set_keymap(0, "c", "<Esc>", "<C-c>", { noremap = true }) end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = "SearchKeySwap",
    pattern = "/",
    callback = function() vim.api.nvim_buf_del_keymap(0, "c", "<Esc>") end,
})
