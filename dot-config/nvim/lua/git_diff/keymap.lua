local map = vim.keymap.set
local opt = { noremap = true, silent = true }
local g_util = require("utils")

-- git status 관리
map("n", ",g", "<cmd>topleft G<CR>", opt) -- shortcut
map("n", "<leader>gc", OpenCommitMsg, opt) -- shortcut
map("v", "<leader>gc", Commit_with_selected, opt)
map("n", "<leader>ga", AmendCommitMsg, opt)

-- GITSIGNS
map("n", "gsth", "<cmd>Gitsigns stage_hunk | NvimTreeRefresh<CR>", opt) -- stage hunk
map("v", "gsth", Visual_stage, opt) -- stage hunk
map("v", "gstu", Visual_undo_stage, opt) -- stage hunk
map("n", "gstb", "<cmd>Gitsigns stage_buffer | NvimTreeRefresh<CR>", opt) -- stage buffer
map("n", "greh", "<cmd>Gitsigns reset_hunk | NvimTreeRefresh<CR>", opt) -- reset hunk, de-active
map("v", "greh", Visual_reset, opt) -- reset hunk, de-active
map("n", "gpre", "<cmd>Gitsigns preview_hunk<CR>", opt) -- show diff
map("n", "gbl", "<cmd>Gitsigns blame_line<CR>", opt) -- show diff

local wk_map = require("utils").wk_map
wk_map({ ["<leader>g"] = { group = "󰊢  Git" } })
wk_map({
    -- git log
    ["<leader>gl"] = {
        group = "Log",
        order = { "<Space>", "a", "r", "f" },
        ["<Space>"] = { "<cmd>GV<CR>", desc = "(default)", mode = "n" },
        ["a"] = { "<cmd>GV --all<CR>", desc = "all", mode = "n" },
        ["r"] = { "<cmd>GV reflog<CR>", desc = "reflog", mode = "n" },
        ["f"] = { "<cmd>GV!<CR>", desc = "current File", mode = "n" },
    },
})
wk_map({
    -- git review
    ["<leader>gr"] = {
        group = "Review",
        order = { "w", "s", "<Space>", "f", "a", "F" },
        ["w"] = { "<cmd>DiffviewOpen<CR>", desc = "working on", mode = { "n" } },
        ["s"] = { "<cmd>DiffviewOpen --staged<CR>", desc = "staged", mode = { "n" } },
        ["<Space>"] = {
            function()
                local mode = vim.fn.mode()
                if mode == "n" then
                    vim.cmd("DiffviewFileHistory")
                else
                    DiffviewOpenWithVisualHash()
                end
            end,
            desc = "normal or visual-selected",
            mode = { "n", "v" },
        },
        ["f"] = { "<cmd>DiffviewFileHistory %<CR>", desc = "file", mode = { "n" } },
        ["a"] = { "<cmd>DiffviewFileHistory --all<CR>", desc = "all", mode = { "n" } },
        ["F"] = { "<cmd>DiffviewFileHistory --reverse --range=HEAD...FETCH_HEAD<CR>", desc = "fetched", mode = { "n" } },
        ["r"] = {
            function()
                vim.fn.feedkeys(":DiffviewFileHistory --range=", "n")
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "c", false)
            end,
            desc = "range select",
            mode = { "n" },
        },
    },
})
