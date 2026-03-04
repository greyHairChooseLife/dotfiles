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
    },
})
