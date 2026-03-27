local map = vim.keymap.set
local opt = { noremap = true, silent = true }
local wk_map = require("utils").wk_map

-- MEMO:: Window Size
local window_size = require("UI.modules.window_size")
wk_map({
    [",w"] = {
        group = "Window Size",
        order = { "f", "A", "U" },
        ["f"] = {
            function() window_size.toggleWinFix() end,
            desc = "fix (toggle)",
            mode = "n",
        },
        ["A"] = {
            function() window_size.toggleAllWinFix() end,
            desc = "fix all",
            mode = "n",
        },
        ["U"] = {
            function() window_size.unfixAllWindows() end,
            desc = "unfix all",
            mode = "n",
        },
    },
})

-- MEMO:: Etc
wk_map({
    ["<Space>u"] = {
        group = "UI",
        order = { "i", "s", "S", "d" },
        ["i"] = { "<cmd>IBLToggle<CR>", desc = "IBL-toggle", mode = "n" },
        ["s"] = {
            function()
                local cur = vim.wo.signcolumn
                vim.wo.signcolumn = cur == "no" and "yes" or "no"
            end,
            desc = "signcolumn toggle (win)",
            mode = "n",
        },
        ["S"] = {
            function()
                local wins = vim.tbl_filter(function(win)
                    local buf = vim.api.nvim_win_get_buf(win)
                    return vim.api.nvim_get_option_value("buftype", { buf = buf }) ~= "nofile"
                end, vim.api.nvim_list_wins())
                if #wins == 0 then return end
                local first = vim.api.nvim_get_option_value("signcolumn", { win = wins[1] })
                local next = first == "no" and "yes" or "no"
                for _, win in ipairs(wins) do
                    vim.api.nvim_set_option_value("signcolumn", next, { win = win })
                end
            end,
            desc = "signcolumn toggle (all wins)",
            mode = "n",
        },
        ["v"] = { ToggleVirtualText, desc = "virtual text toggle", mode = { "n" } },
        ["r"] = { "<cmd>RenderMarkdown buf_toggle<CR>", desc = "  rendering toggle", mode = { "n" } },
        ["c"] = { "<cmd>HighlightColors Toggle<CR>", desc = "Color toggle", mode = { "n" } },
    },
})

map({ "n", "v" }, "w", function()
    local line = vim.fn.line(".")
    if vim.fn.foldclosed(line) ~= -1 then
        vim.cmd("normal! zv0w")
    else
        vim.cmd("normal! w")
    end
end, { noremap = true, silent = true })

-- 다음 접힌 라인으로 이동
map({ "n", "v" }, "zn", function()
    local cur = vim.fn.line(".")
    local last = vim.fn.line("$")

    -- 현재 커서가 fold 안에 있으면 해당 fold의 끝으로 건너뜀
    local fold_end = vim.fn.foldclosedend(cur)
    local start = fold_end ~= -1 and fold_end + 1 or cur + 1

    for l = start, last do
        if vim.fn.foldclosed(l) == l then
            vim.api.nvim_win_set_cursor(0, { l, 0 })
            -- vim.cmd("normal! zz")
            return
        end
    end
end, { noremap = true, silent = true })

-- 이전 접힌 라인으로 이동
map({ "n", "v" }, "zp", function()
    local cur = vim.fn.line(".")

    -- 현재 커서가 fold 안에 있으면 해당 fold의 시작으로 건너뜀
    local fold_start = vim.fn.foldclosed(cur)
    local start = fold_start ~= -1 and fold_start - 1 or cur - 1

    for l = start, 1, -1 do
        if vim.fn.foldclosed(l) == l then
            vim.api.nvim_win_set_cursor(0, { l, 0 })
            -- vim.cmd("normal! zz")
            return
        end
    end
end, { noremap = true, silent = true })

map({ "n", "v" }, "zN", "<cmd>normal! zj<CR>", { noremap = true, silent = true })
map({ "n", "v" }, "zP", "<cmd>normal! zk<CR>", { noremap = true, silent = true })
