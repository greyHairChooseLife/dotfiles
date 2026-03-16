local M = {}

M.safe_require = function(module)
    local ok, _ = pcall(require, module)
    -- if not ok then
    --     vim.notify("Module " .. module .. " not found", vim.log.levels.WARN)
    -- end
end

M.auto_mkdir = function()
    local dir = vim.fn.expand("<afile>:p:h")

    -- This handles URLs using netrw. See ':help netrw-transparent' for details.
    if dir:find("%l+://") == 1 then return end

    if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, "p") end
end

M.url_encode = function(str)
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w %-%_%.%~])", function(c) return string.format("%%%02X", string.byte(c)) end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

---@param include_linebreak boolean|nil 기본적으로는 줄바꿈을 다 없앤다. `string.gsub(text, "\n", "")`
---@return string|nil
M.get_visual_text = function(include_linebreak)
    vim.cmd('noau normal! "vy"')
    local text = vim.fn.getreg("v")
    vim.fn.setreg("v", {})

    if include_linebreak == false then
        -- 이게 왜 필요했던건지 모르겠지만 일단...
        text = string.gsub(text, "\n", "")
    end
    if #text > 0 then
        return text
    else
        return nil
    end
end

---
--- 선택된 텍스트의 시작줄과 끝줄 **번호**를 반환합니다.
---
--- @return number startLine 선택된 텍스트의 시작 라인 번호
--- @return number endLine 선택된 텍스트의 끝 라인 번호
M.get_visual_line = function()
    local selectedLines = { vim.fn.getpos("v")[2], vim.fn.getpos(".")[2] }
    -- 선택 범위 정렬
    local startLine = math.min(selectedLines[1], selectedLines[2])
    local endLine = math.max(selectedLines[1], selectedLines[2])

    return startLine, endLine
end

M.is_buffer_active_somewhere = function(bufnr)
    -- Get the current window ID
    local current_winid = vim.api.nvim_get_current_win()

    -- Check all windows
    local windows = vim.api.nvim_list_wins()
    for _, winid in ipairs(windows) do
        -- Skip the current window in our check
        if winid ~= current_winid and vim.api.nvim_win_is_valid(winid) then
            -- Check if the buffer is displayed in this other window
            if vim.api.nvim_win_get_buf(winid) == bufnr then
                return true -- Buffer is active in at least one other window
            end
        end
    end
    return false -- Buffer is not displayed in any other window
end

M.close_empty_unnamed_buffers = function()
    -- 현재 모든 윈도우에 로드된 활성 버퍼 목록 가져오기
    local active_buffers = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        active_buffers[buf] = true
    end

    -- 모든 버퍼를 확인하면서, 비어있고 이름이 없는 비활성 버퍼를 닫기
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == "" and not active_buffers[buf] then
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            if #lines == 0 or (#lines == 1 and lines[1] == "") then vim.api.nvim_buf_delete(buf, { force = true }) end
        end
    end
end

M.get_current_tabname = function()
    local tabnr = vim.fn.tabpagenr()
    return vim.fn.gettabvar(tabnr, "tabname", "No Name")
end

-- 밀리초 아니고 그냥 초
M.print_in_time = function(msg, time)
    -- message history에는 남기지 않는다.
    vim.api.nvim_echo({ { msg } }, false, {})

    -- vim.defer_fn(function()
    --   vim.api.nvim_echo({{''}}, false, {})  -- 빈 문자열로 메시지 지우기
    -- end, time * 1000)
    -- 성능 이슈가 있어 아래를 사용한다.
    local timer = vim.loop.new_timer()
    timer:start(
        time * 1000,
        0,
        vim.schedule_wrap(function()
            vim.api.nvim_echo({ { "" } }, false, {}) -- 빈 문자열로 메시지 지우기
            timer:stop()
            timer:close()
        end)
    )
end

M.tree = {
    api = require("nvim-tree.api"),
    is_visible = function(self) return self.api.tree.is_visible() end,
    open = function(self)
        local tree_api = self.api.tree

        tree_api.toggle({ find_files = true, focus = false })
        if self:is_visible() then ShowCursor() end
    end,
}

---@param FT string 파일타입
M.close_FT_buffers = function(FT)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            -- local filetype = vim.api.nvim_buf_get_option(buf, "filetype") -- deprecated
            local filetype = vim.api.nvim_get_option_value("filetype", { scope = "local" })
            if filetype == FT then vim.api.nvim_buf_delete(buf, { force = true }) end
        end
    end
end

M.borders = {
    diagnostics = {
        { "-", "DiagnosticsBorder" },
        { "-", "DiagnosticsBorder" },
        { "-", "DiagnosticsBorder" },
        { " ", "DiagnosticsBorder" },
        { "-", "DiagnosticsBorder" },
        { "-", "DiagnosticsBorder" },
        { "-", "DiagnosticsBorder" },
        { " ", "DiagnosticsBorder" },
    },
    documentation = {
        { "-", "BlinkCmpDocBorder" },
        { "-", "BlinkCmpDocBorder" },
        { "-", "BlinkCmpDocBorder" },
        { " ", "BlinkCmpDocBorder" },
        { "-", "BlinkCmpDocBorder" },
        { "-", "BlinkCmpDocBorder" },
        { "-", "BlinkCmpDocBorder" },
        { " ", "BlinkCmpDocBorder" },
    },
    documentation_left = {
        { "", "BlinkCmpDocBorder" },
        { "", "BlinkCmpDocBorder" },
        { "", "BlinkCmpDocBorder" },
        { " ", "BlinkCmpDocBorder" },
        { "", "BlinkCmpDocBorder" },
        { "", "BlinkCmpDocBorder" },
        { "", "BlinkCmpDocBorder" },
        { "▌", "BlinkCmpDocBorder" },
    },
    signature = {
        { "▌", "BlinkCmpSignatureHelpBorder" },
        { " ", "BlinkCmpSignatureHelpBorder" },
        { " ", "BlinkCmpSignatureHelpBorder" },
        { " ", "BlinkCmpSignatureHelpBorder" },
        { " ", "BlinkCmpSignatureHelpBorder" },
        { " ", "BlinkCmpSignatureHelpBorder" },
        { "▌", "BlinkCmpSignatureHelpBorder" },
        { "▌", "BlinkCmpSignatureHelpBorder" },
    },
    git_preview = "single",
    -- git_preview = {
    -- 	{ "", "GitSignsPreviewBorder" },
    -- 	{ "", "GitSignsPreviewBorder" },
    -- 	{ "", "GitSignsPreviewBorder" },
    -- 	{ " ", "GitSignsPreviewBorder" },
    -- 	{ " ", "GitSignsPreviewBorder" },
    -- 	{ " ", "GitSignsPreviewBorder" },
    -- 	{ " ", "GitSignsPreviewBorder" },
    -- 	{ " ", "GitSignsPreviewBorder" },
    -- },
    full = {
        "▄",
        "▄",
        "▄",
        "█",
        "▀",
        "▀",
        "▀",
        "█",
    },
}

M.icons = {
    diagnostics = {
        Error = " ",
        Warn = " ",
        Hint = " ",
        Info = " ",
    },
    git = {
        Add = "+",
        Change = "~",
        Delete = "-",
    },
    etc = {
        modified = "󰈸󰈸󰈸", --   
    },
    nvimtree_git = {
        unstaged = "󰍶", --  󱠇  󰅙   󰍶
        staged = "󰗠", --     󰗠 󰗡 󰄲 󰄴 󱤧 󰄵 󰱒
        unmerged = "",
        renamed = "", --      
        untracked = "󰋗 ", --       󰅗 󰅘 󰅙 󰅚 󰅜 󰅝 󱍥 󱍦
        deleted = "", -- 󰗨 󰺝 󰛌
        ignored = "",
    },
    kinds = {
        Array = "󰅪",
        Branch = "",
        Boolean = "󰨙",
        Class = "󰠱",
        Color = "󰏘",
        Constant = "󰏿",
        Constructor = "",
        Enum = "",
        EnumMember = "",
        Event = "",
        Field = "",
        File = "",
        Folder = "󰉋",
        Function = "󰊕",
        Interface = "",
        Key = "",
        Keyword = "󰌋",
        Method = "󰆧",
        Module = "󰏗 ",
        Namespace = "󰅩",
        Number = "󰎠",
        Null = "",
        Object = "",
        Operator = "+",
        Package = "",
        Property = "󰜢",
        Reference = "",
        Snippet = "",
        String = "𝓐",
        Struct = "󰙅",
        Text = "",
        TypeParameter = "󰆩",
        Unit = "",
        Value = "󰎠",
        Variable = "󰀫",
    },
    cmp_sources = {
        LSP = "✨",
        Luasnip = "🚀",
        Buffer = "📝",
        Path = "📁",
        Cmdline = "💻",
    },
}

-- # 사용 방법
-- 하나, $HOME/.config/nvim/lua/qol/plugins.lua에서 'which-key triggers'를 찾아 prefix에 해당하는 것을 등록한다.
--   둘, 유틸 함수를 불러와 사용한다.
--
-- # 사용 예시
-- local wk_map = require("utils.wk_map")
-- wk_map({
--     ["<leader>f"] = {
--         group = "Find",
--         order = { "f", "g" }, -- 순서 정의
--         ["f"] = { "<cmd>Telescope find_files<CR>", desc = "파일 찾기", mode = "n", silent = true, buffer = 0 },
--         ["g"] = { "<cmd>Telescope live_grep<CR>", desc = "텍스트 검색", mode = "n" },
--     }
-- })
--
-- # 추가 옵션
-- :help map-arguments
--   "<buffer>", "<nowait>", "<silent>", "<script>", "<expr>" and
--   "<unique>" can be used in any order.  They must appear right after the
--   command, before any other arguments.
M.wk_map = function(mappings)
    local processed = {}
    for group_prefix, group_mappings in pairs(mappings) do
        -- Add group definition
        processed[#processed + 1] = { group_prefix, group = group_mappings.group }

        -- Create ordered mappings array
        local ordered_mappings = {}
        for key, mapping in pairs(group_mappings) do
            if key ~= "group" and key ~= "order" then ordered_mappings[#ordered_mappings + 1] = { key = key, mapping = mapping } end
        end

        -- Sort based on order if provided
        if group_mappings.order then
            local order_lookup = {}
            for i, key in ipairs(group_mappings.order) do
                order_lookup[key] = i
            end

            table.sort(ordered_mappings, function(a, b)
                local a_order = order_lookup[a.key] or 999
                local b_order = order_lookup[b.key] or 999
                return a_order < b_order
            end)
        end

        -- Process each mapping in order
        for _, item in ipairs(ordered_mappings) do
            local map = vim.deepcopy(item.mapping)
            processed[#processed + 1] = {
                group_prefix .. item.key,
                map[1],
                desc = "➜ " .. map.desc,
                mode = map.mode,
                silent = map.silent == nil and true or map.silent,
                buffer = map.buffer == nil and false or map.buffer,
                noremap = true,
            }
        end
    end
    require("which-key").add(processed)
end

local saved_cursor_normal = nil -- 커서 위치 및 윈도우 저장 변수
local saved_cursor_for_commit_msg = nil

-- 현재 커서 위치와 윈도우 저장
---@param for_commit_msg boolean? 커밋 메시지 작성에 사용하는가
---@return table { win, buf, row, col }
M.save_cursor_position = function(for_commit_msg)
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_win_get_buf(win)
    local row, col = unpack(vim.api.nvim_win_get_cursor(win))

    local cursor_data = { win = win, buf = buf, row = row, col = col, is_fugitive = vim.bo[buf].filetype == "fugitive" }

    if for_commit_msg then
        saved_cursor_for_commit_msg = cursor_data
    else
        saved_cursor_normal = cursor_data
    end

    return cursor_data
end

-- 저장된 위치로 이동
---@param for_commit_msg boolean? 커밋 메시지 작성에 사용하는가
M.restore_cursor_position = function(for_commit_msg)
    local saved_cursor = not for_commit_msg and saved_cursor_normal or saved_cursor_for_commit_msg

    if saved_cursor then
        -- 윈도우가 여전히 유효한지 확인
        if vim.api.nvim_win_is_valid(saved_cursor.win) then
            -- 먼저 해당 윈도우로 이동
            if saved_cursor.is_fugitive then
                vim.cmd("G")
            else
                vim.api.nvim_set_current_win(saved_cursor.win)
            end

            -- 버퍼가 변경되었는지 확인
            local current_buf = vim.api.nvim_win_get_buf(saved_cursor.win)
            if current_buf == saved_cursor.buf then
                -- 저장된 커서 위치로 이동
                vim.api.nvim_win_set_cursor(saved_cursor.win, { saved_cursor.row, saved_cursor.col })
            -- print("Cursor position restored to Window " .. saved_cursor.win)
            else
                print("Buffer has changed in the target window")
            end
        else
            print("Saved window is no longer valid")
        end
    else
        print("No saved cursor position")
    end
end

--- 특정 파일 타입이 열려 있는지 확인하는 함수
--- @param filetype string 찾고자 하는 파일 타입
--- @param tabid number|nil 검색할 탭 ID (기본값: 0, 현재 탭)
--- @return boolean
M.is_filetype_open = function(filetype, tabid)
    tabid = tabid or 0
    -- Get all windows in current tab
    local wins = vim.api.nvim_tabpage_list_wins(tabid)

    -- Check each window's buffer filetype
    for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if ft == filetype then return true end
    end

    return false
end

-- 사용법: local win, restore = get_window_preserver()
M.get_window_preserver = function()
    local win = vim.api.nvim_get_current_win()
    local function restore()
        vim.defer_fn(function()
            if vim.api.nvim_win_is_valid(win) then vim.api.nvim_set_current_win(win) end
        end, 1)
    end
    return win, restore
end

M.get_project_name_by_cwd = function()
    local project_directory, err = vim.uv.cwd()
    if project_directory == nil then
        vim.notify(err or "Unknown error getting current directory", vim.log.levels.WARN)
        return nil
    end

    local project_name = vim.fs.basename(project_directory)
    if project_name == nil then
        vim.notify("Unable to get the project name", vim.log.levels.WARN)
        return nil
    end

    return project_name
end

---Gets the project name by finding the git root directory
---@class GetProjectNameByGitOpts
---@field print_errors? boolean Whether to print errors (defaults to true)
---@param opts? GetProjectNameByGitOpts Optional configuration table
---@return string|nil project_name Returns the project name or nil if not found
M.get_project_name_by_git = function(opts)
    opts = opts or {}
    local print_errors = opts.print_errors ~= false

    local result = vim.system({
        "git",
        "rev-parse",
        "--show-toplevel",
    }, {
        text = true,
    }):wait()

    if result.stderr ~= "" then
        if print_errors then vim.notify(result.stderr, vim.log.levels.WARN) end
        return nil
    end

    local project_directory = result.stdout:gsub("\n", "")

    local project_name = vim.fs.basename(project_directory)
    if project_name == nil then
        if print_errors then vim.notify("Unable to get the project name", vim.log.levels.WARN) end
        return nil
    end

    return project_name
end

--- show/hide cursor
M.cursor = {
    show = function()
        vim.cmd("hi Cursor blend=0")
        vim.cmd("set guicursor-=a:Cursor/lCursor")
    end,

    hide = function()
        vim.cmd("hi Cursor blend=100")
        vim.cmd("set guicursor+=a:Cursor/lCursor")
    end,
}

---Sets a Neovim option value with the specified scope
--->
---@param option string The option name to set
---@param value any The value to set the option to
---@param opts? table Optional settings table with scope (defaults to {scope = "local"})
M.setOpt = function(option, value, opts)
    opts = opts or { scope = "local" }
    vim.api.nvim_set_option_value(option, value, opts)
end

---Temporarily highlight a range of text in the current buffer
---@param start_line number The first line to highlight (1-indexed)
---@param end_line number The last line to highlight (1-indexed)
---@param highlight_group string|nil The highlight group to use (default: "Visual")
---@param duration_ms number|nil Duration in milliseconds before the highlight disappears (default: 100)
---@return nil
M.highlight_text_temporarily = function(start_line, end_line, highlight_group, duration_ms)
    -- Set defaults
    highlight_group = highlight_group or "Visual"
    duration_ms = duration_ms or 100

    local ns_id = vim.api.nvim_create_namespace("temp_highlight")

    -- Clear any existing highlights
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

    -- Highlight the specified lines
    for i = start_line, end_line do
        vim.highlight.range(0, ns_id, highlight_group, { i - 1, 0 }, { i - 1, -1 }, {})
    end

    -- Clear the highlight after the specified duration
    vim.defer_fn(function() vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1) end, duration_ms)
end

---현재 탭 또는 모든 탭에서 마지막 창인지 확인하는 함수
---@param current_tab_only boolean? 현재 탭만 확인할지 여부
---@return boolean 마지막 창인지 여부
M.is_last_window = function(current_tab_only)
    local win_count = #vim.api.nvim_tabpage_list_wins(0)
    local is_last_window = win_count == 1

    -- If requested, also check if there's only one tab
    if current_tab_only then
        local tab_count = #vim.api.nvim_list_tabpages()
        return is_last_window and tab_count == 1
    end

    return is_last_window
end

--- Check if a buffer is shown only in the current tab
-- @param buf_id number: The buffer ID to check
-- @return boolean: true if the buffer is shown only in the current tab, false otherwise
M.is_buffer_shown_only_in_current_tab = function(buf_id)
    local current_tab = vim.api.nvim_get_current_tabpage()
    local win_with_buf_count = 0
    local win_with_buf_in_current_tab_count = 0

    -- Iterate through all windows
    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
        -- If window shows the specified buffer
        if vim.api.nvim_win_get_buf(win_id) == buf_id then
            win_with_buf_count = win_with_buf_count + 1

            -- If window is in the current tab
            if vim.api.nvim_win_get_tabpage(win_id) == current_tab then win_with_buf_in_current_tab_count = win_with_buf_in_current_tab_count + 1 end
        end
    end

    -- Buffer is shown only in current tab if all windows showing it are in current tab
    return win_with_buf_count > 0 and win_with_buf_count == win_with_buf_in_current_tab_count
end

local check_is_alacritty = function()
    for k, _ in pairs(vim.fn.environ()) do
        if k:match("^ALACRITTY_") then return true end
    end

    return false
end

M.is_alacritty = check_is_alacritty()

-- Function to check if a file exists
M.file_exists = function(filepath)
    local f = io.open(filepath, "rb")
    if f then f:close() end
    return f ~= nil
end

M.get_tab_id_from_order = function(order_number)
    local tabpages = vim.api.nvim_list_tabpages()
    return tabpages[order_number]
end

M.switch_to_normal_mode = function()
    local escape_key = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
    vim.api.nvim_feedkeys(escape_key, "n", true)
end

M.feed_keys_with_delay = function(keys, delay)
    local i = 1
    local function feed_next()
        if i <= #keys then
            vim.api.nvim_feedkeys(keys[i], "n", false)
            i = i + 1
            vim.defer_fn(feed_next, delay)
        end
    end
    feed_next()
end

--- Copy the current buffer's path to a register.
---@param mode  "directory" | "absolute" | "relative" | "filename"
---@return nil
M.copy_path = function(mode)
    local path
    if mode == "absolute" then
        path = vim.fn.expand("%:p")
    elseif mode == "relative" then
        local abs_path = vim.fn.expand("%:p")
        local cwd = vim.fn.getcwd()
        -- fnamemodify로 상대화
        path = vim.fn.fnamemodify(abs_path, ":." .. cwd)
    elseif mode == "filename" then
        path = vim.fn.expand("%:t")
    elseif mode == "directory" then
        path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h")
    else
        vim.notify("Unknown mode: " .. tostring(mode), vim.log.levels.ERROR)
        return
    end

    if path == "" then
        vim.notify("No file name to copy.", vim.log.levels.WARN)
        return
    end

    vim.fn.setreg("+", path)
    vim.notify("Copied " .. mode .. ".\r\n" .. path, vim.log.levels.INFO)
end

--- Copy paths of all buffers shown in the current tab's windows.
---@param mode  "directory" | "absolute" | "relative" | "filename"
---@return nil
M.copy_paths_in_tab = function(mode)
    local wins = vim.api.nvim_tabpage_list_wins(0)
    local seen = {}
    local paths = {}
    for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        local bufname = vim.api.nvim_buf_get_name(buf)
        if bufname ~= "" then
            local path
            if mode == "absolute" then
                path = vim.fn.fnamemodify(bufname, ":p")
            elseif mode == "relative" then
                path = vim.fn.fnamemodify(bufname, ":.")
            elseif mode == "filename" then
                path = vim.fn.fnamemodify(bufname, ":t")
            elseif mode == "directory" then
                path = vim.fn.fnamemodify(bufname, ":p:h")
            end
            if path and path ~= "" and not seen[path] then
                seen[path] = true
                table.insert(paths, path)
            end
        end
    end
    if #paths == 0 then
        vim.notify("No file paths to copy.", vim.log.levels.WARN)
        return
    end
    local result = table.concat(paths, "\n")
    vim.fn.setreg("+", result)
    vim.notify("Copied " .. #paths .. " " .. mode .. " paths.\n" .. result, vim.log.levels.INFO)
end

M.create_floating_window = function(content, filetype, width, height, row, col)
    local lines
    if type(content) == "string" then
        lines = vim.split(content, "\n", { plain = true })
    elseif type(content) == "table" then
        lines = content
    else
        lines = { "Invalid content" }
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    if filetype then vim.api.nvim_buf_set_option(buf, "filetype", filetype) end

    local opts = {
        relative = "editor",
        width = width or 40,
        height = height or #lines, -- Adjust height to content
        row = row or math.floor((vim.o.lines - (height or #lines)) / 2),
        col = col or math.floor((vim.o.columns - (width or 40)) / 2),
        style = "minimal",
        border = "rounded",
    }

    local win = vim.api.nvim_open_win(buf, true, opts)

    M.setOpt("signcolumn", "yes")
    M.setOpt("winhighlight", "SignColumn:DiffviewMessageSignColumn")

    return win, buf
end

M.get_valid_rev = function(rev)
    -- Check if the provided rev is valid
    local result = vim.fn.system({ "git", "rev-parse", "--verify", rev })
    if vim.v.shell_error == 0 then
        return rev -- Return the original if valid
    else
        -- Default to HEAD and verify it (to be safe)
        local head_result = vim.fn.system({ "git", "rev-parse", "--verify", "HEAD" })
        if vim.v.shell_error == 0 then
            return "HEAD"
        else
            error("Neither the provided rev nor HEAD is valid in this repository")
        end
    end
end

return M
