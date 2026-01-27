local utils = require("utils")

local M = {}

-- Config
M.config = {
    tab_ui_min_length = 15,
    tab_ui_max_length = 45,
    float_default_col = 45,
}

function M.nav_buff_after_cleaning(direction)
    utils.close_empty_unnamed_buffers()
    vim.cmd(direction == "prev" and "bprev" or "bnext")

    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname:find("Term: ") then vim.cmd(direction == "prev" and "bprev" or "bnext") end

    local listed_buffers = vim.fn.getbufinfo({ buflisted = 1 })
    local filtered_buffers = vim.tbl_filter(function(buf) return not string.find(buf.name, "Term:") end, listed_buffers)

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

function M.nav_buff_except_current_tab(direction)
    local initial_buf = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()
    local attempts = 0
    local max_attempts = 20

    repeat
        M.nav_buff_after_cleaning(direction)
        local current_buf = vim.api.nvim_get_current_buf()
        attempts = attempts + 1

        local is_visible_elsewhere = false
        for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if win_id ~= current_win and vim.api.nvim_win_get_buf(win_id) == current_buf then
                is_visible_elsewhere = true
                break
            end
        end

        if attempts >= max_attempts or current_buf == initial_buf then break end
    until not is_visible_elsewhere
end

function M.buffer_next_drop_last()
    local last_buf = vim.api.nvim_get_current_buf()

    M.nav_buff_except_current_tab("next")

    if vim.api.nvim_buf_is_valid(last_buf) then
        if last_buf == vim.api.nvim_get_current_buf() then
            vim.fn.feedkeys("gq")
        else
            vim.cmd("bd " .. last_buf)
        end
    end
end

function M.close_other_buffers_in_tab()
    local current_buf_id = vim.api.nvim_get_current_buf()
    local current_win_id = vim.api.nvim_get_current_win()
    local current_tab_id = vim.api.nvim_get_current_tabpage()
    local window_ids = vim.api.nvim_tabpage_list_wins(current_tab_id)

    local excluded_buftypes = { "nofile" }

    for _, win_id in ipairs(window_ids) do
        if not vim.api.nvim_win_is_valid(win_id) then goto continue end

        local buf_id = vim.api.nvim_win_get_buf(win_id)
        if win_id ~= current_win_id and buf_id ~= current_buf_id then
            if utils.is_buffer_shown_only_in_current_tab(buf_id) and not vim.tbl_contains(excluded_buftypes, vim.bo[buf_id].buftype) then
                vim.api.nvim_buf_delete(buf_id, { force = true })
            else
                M.gq(nil, win_id)
            end
        end

        ::continue::
    end

    vim.cmd("only")
end

function M.tab_only_close_hidden()
    vim.cmd("TTimerlyClose")
    local open_buffers = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        open_buffers[buf] = true
    end

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if not open_buffers[buf] and vim.api.nvim_buf_is_loaded(buf) then
            local filetype = vim.bo[buf].filetype
            if filetype ~= "VoltWindow" then vim.api.nvim_buf_delete(buf, { force = true }) end
        end
    end

    vim.cmd("silent tabonly")
    vim.notify("Tab only, wiped invisible buffers", vim.log.levels.INFO)
end

local function close_if_last_with_nvimtree()
    local all_windows = vim.fn.getbufinfo({ buflisted = 1 })
    -- local all_windows = vim.api.nvim_list_wins()

    if #all_windows == 2 then
        local current_win = vim.api.nvim_get_current_win()
        local other_win

        for _, win in ipairs(all_windows) do
            if win ~= current_win then
                other_win = win
                break
            end
        end

        if other_win then
            -- local buf = vim.api.nvim_win_get_buf(other_win.bufnr)
            local buf = other_win.bufnr
            if vim.bo[buf].filetype == "NvimTree" then M.gQ() end
        end
    end
end

---@param bufnr integer?
---@param winid integer?
function M.gq(bufnr, winid)
    bufnr = bufnr or (winid and vim.api.nvim_win_get_buf(winid)) or vim.fn.bufnr("%")

    if not vim.api.nvim_buf_is_valid(bufnr) then return vim.notify(bufnr .. " is not valid bufnr.", vim.log.levels.ERROR) end

    local excluded_filetypes = { "help", "gitcommit", "NvimTree", "codecompanion" }
    local excluded_buftypes = { "nofile" }

    local is_buflisted = vim.bo[bufnr].buflisted
    local bufname_empty = vim.fn.bufname(bufnr) == ""
    local buffer_active_in_other_window = utils.is_buffer_active_somewhere(bufnr)
    local excluded_filetype = vim.tbl_contains(excluded_filetypes, vim.bo[bufnr].filetype)
    local excluded_buftype = vim.tbl_contains(excluded_buftypes, vim.bo[bufnr].buftype)

    if is_buflisted and not bufname_empty and not buffer_active_in_other_window and not excluded_filetype and not excluded_buftype then
        if #vim.fn.getbufinfo({ buflisted = 1 }) == 1 then
            if utils.tree:is_visible() then
                M.gQ()
            else
                vim.cmd("q")
            end
            return
        end
        -- close_if_last_with_nvimtree()
        vim.cmd.bdelete(bufnr)
        return
    end

    if utils.is_last_window() then return vim.cmd("q!") end

    if vim.bo[bufnr].filetype == "NvimTree" then return vim.cmd("q!") end

    vim.api.nvim_win_close(winid or 0, false)
end

function M.ge()
    vim.cmd("w")
    M.gq()
    vim.notify("Saved and closed buffer", vim.log.levels.INFO)
end

function M.gQ()
    local bufnr = vim.fn.bufnr("%")
    vim.cmd("q")
    if vim.api.nvim_buf_is_valid(bufnr) then vim.api.nvim_buf_delete(bufnr, { force = true }) end
end

function M.gE()
    vim.cmd("w")
    M.gQ()
    vim.notify("Saved and wiped buffer", vim.log.levels.INFO)
end

function M.gtq()
    if require("nvim-tree.api").tree.is_visible() then vim.cmd("NvimTreeClose") end

    local special_tabs = { " Commit", " File", "GV", "Diff" }
    local tabname = utils.get_current_tabname()
    if vim.tbl_contains(special_tabs, tabname) then return vim.cmd("tabclose!") end

    local wins = vim.api.nvim_tabpage_list_wins(0)
    for _, win in ipairs(wins) do
        if vim.api.nvim_win_is_valid(win) then
            local bufnr = vim.api.nvim_win_get_buf(win)
            M.gq(bufnr)
        end
    end
end

function M.gtQ() vim.notify("Rarely used. Consider removing.", vim.log.levels.WARN) end

function M.focus_floating_window()
    local wins = vim.api.nvim_list_wins()
    for _, win in ipairs(wins) do
        local config = vim.api.nvim_win_get_config(win)
        if config.focusable and config.relative ~= "" then
            vim.api.nvim_set_current_win(win)
            return
        end
    end
end

function M.new_tab_with_prompt()
    local on_confirm = function(value)
        if not value or value == "" then return end
        vim.cmd("tabnew")
        local tabnr = vim.fn.tabpagenr()
        vim.fn.settabvar(tabnr, "tabname", value)
    end

    Snacks.input.input({
        icon = "",
        prompt = "new tab",
        default = "",
        win = {
            style = {
                row = vim.api.nvim_win_get_height(0) / 2 - 3,
            },
        },
    }, on_confirm)
end

function M.rename_current_tab()
    local current_tabname = vim.t[0].tabname
    if current_tabname == nil or current_tabname == vim.NIL then current_tabname = "" end

    local cfg = M.config

    local prev_tab_ui_length = function(cur_tabnr)
        if cur_tabnr <= 1 then return 0 end

        local prev_tabname = vim.t[utils.get_tab_id_from_order(cur_tabnr - 1)].tabname
        if prev_tabname == nil or prev_tabname == vim.NIL then prev_tabname = "" end

        if #prev_tabname > cfg.tab_ui_min_length then
            if #prev_tabname < cfg.tab_ui_max_length then
                return #prev_tabname + 6
            else
                return cfg.tab_ui_max_length + 6
            end
        else
            return cfg.tab_ui_min_length + 3
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
        if not value or value == "" then return end
        vim.fn.settabvar(tabnr, "tabname", value)
        vim.cmd("redrawtabline")
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

function M.move_tab_left()
    local current_tab = vim.fn.tabpagenr()
    if current_tab == 1 then
        vim.cmd("tabmove $")
    elseif current_tab > 1 then
        vim.cmd("tabmove " .. (current_tab - 2))
    end
end

function M.move_tab_right()
    local current_tab = vim.fn.tabpagenr()
    local total_tabs = vim.fn.tabpagenr("$")
    if current_tab < total_tabs then
        vim.cmd("tabmove " .. current_tab + 1)
    else
        vim.cmd("tabmove 0")
    end
end

function M.split_tab_modify_tabname()
    vim.cmd("split | wincmd T")
    local tabnr = vim.fn.tabpagenr()
    local filename = vim.fn.expand("%:t")
    if filename ~= "" then vim.fn.settabvar(tabnr, "tabname", " sp: " .. filename) end
end

function M.move_tab_modify_tabname()
    vim.cmd("wincmd T")
    local tabnr = vim.fn.tabpagenr()
    local filename = vim.fn.expand("%:t")
    if filename ~= "" then vim.fn.settabvar(tabnr, "tabname", " mv: " .. filename) end
end

---@class FloatWindowOpts
---@field filepath string?
---@field content string[]?
---@field width number?
---@field height number?
---@field col number?
---@field row number?
---@field relative string?
---@field style string?
---@field border string?
---@param opts FloatWindowOpts?
---@return number win
---@return number buf
function M.open_float_window(opts)
    opts = opts or {}

    local buf = vim.api.nvim_create_buf(false, true)

    if opts.filepath then
        local existing_bufnr = -1
        for _, bufid in ipairs(vim.api.nvim_list_bufs()) do
            local bufname = vim.api.nvim_buf_get_name(bufid)
            if bufname == opts.filepath then
                existing_bufnr = bufid
                break
            end
        end

        if existing_bufnr ~= -1 then
            vim.api.nvim_buf_delete(buf, { force = true })
            buf = existing_bufnr
        else
            local lines = {}
            local file = io.open(opts.filepath, "r")
            if file then
                for line in file:lines() do
                    table.insert(lines, line)
                end
                file:close()
                vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
                pcall(vim.api.nvim_buf_set_name, buf, opts.filepath)
                vim.bo[buf].buftype = ""
                vim.bo[buf].modifiable = true
                local filetype = vim.filetype.match({ filename = opts.filepath })
                if filetype then vim.bo[buf].filetype = filetype end
            else
                vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "Could not open file: " .. opts.filepath })
            end
        end
    elseif opts.content then
        local lines = type(opts.content) == "table" and opts.content or { opts.content }
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
    else
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, { "Empty floating window" })
    end

    local width = opts.width or math.floor(vim.o.columns * 0.7)
    local height = opts.height or math.floor(vim.o.lines * 0.8)
    local col = opts.col or M.config.float_default_col
    local row = opts.row or math.floor((vim.o.lines - height) / 4)

    local win_opts = {
        relative = opts.relative or "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = opts.style or "minimal",
        border = opts.border or "single",
    }

    local win = vim.api.nvim_open_win(buf, true, win_opts)
    local setOpt = utils.setOpt
    setOpt("winhighlight", "Normal:Normal,EndOfBuffer:EndOfBuffer")
    setOpt("number", true)
    setOpt("relativenumber", true)
    setOpt("signcolumn", "no")

    return win, buf
end

function M.close_all_hidden_buffers()
    local listed_buffers = vim.fn.getbufinfo({ buflisted = 1 })
    local visible_buffers = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        visible_buffers[buf] = true
    end

    for _, bufinfo in ipairs(listed_buffers) do
        local buf = bufinfo.bufnr
        if not visible_buffers[buf] then vim.api.nvim_buf_delete(buf, {}) end
    end
end

-- Backward compatibility: expose as globals
NavBuffAfterCleaning = M.nav_buff_after_cleaning
NavBuffAfterCleaningExceptCurrentTabShowing = M.nav_buff_except_current_tab
BufferNextDropLast = M.buffer_next_drop_last
CloseOtherBuffersInCurrentTab = M.close_other_buffers_in_tab
TabOnlyAndCloseHiddenBuffers = M.tab_only_close_hidden
ManageBuffer_ge = M.ge
ManageBuffer_gq = M.gq
ManageBuffer_gQ = M.gQ
ManageBuffer_gE = M.gE
ManageBuffer_gtq = M.gtq
ManageBuffer_gtQ = M.gtQ
FocusFloatingWindow = M.focus_floating_window
NewTabWithPrompt = M.new_tab_with_prompt
RenameCurrentTab = M.rename_current_tab
MoveTabLeft = M.move_tab_left
MoveTabRight = M.move_tab_right
SplitTabModifyTabname = M.split_tab_modify_tabname
MoveTabModifyTabname = M.move_tab_modify_tabname
OpenFloatWindow = M.open_float_window
Close_all_hidden_buffers = M.close_all_hidden_buffers

return M
