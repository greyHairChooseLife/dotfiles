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
    -- diffview open (file tree style)
    ["<leader>gd"] = {
        group = "󰕜  Diff (file tree style)",
        order = { "w", "s", "R", "r", "?" },
        ["w"] = { "<cmd>DiffviewOpen --imply-local<CR>", desc = "working on", mode = { "n" } },
        ["s"] = { "<cmd>DiffviewOpen --staged<CR>", desc = "staged", mode = { "n" } },
        ["R"] = {
            function()
                vim.fn.feedkeys(":DiffviewOpen origin/main..", "n")
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "c", false)
            end,
            desc = "origin/main..",
            mode = { "n" },
        },
        ["r"] = {
            function()
                vim.fn.feedkeys(":DiffviewOpen ", "n")
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "c", false)
            end,
            desc = "range select",
            mode = { "n" },
        },
        ["?"] = {
            function()
                local example = [[

Examples:

    " Diff the working tree against the index:
    :DiffviewOpen

    " Diff the working tree against a specific commit:
    :DiffviewOpen HEAD~2
    :DiffviewOpen d4a7b0d

    " Diff a commit range:
    :DiffviewOpen HEAD~4..HEAD~2
    :DiffviewOpen d4a7b0d..519b30e

    " Diff the changes introduced by a specific commit (kind of like
    " `git show d4a7b0d`):
    :DiffviewOpen d4a7b0d^!

    " Diff HEAD against it's merge base in origin/main:
    :DiffviewOpen origin/main...HEAD

    " Limit the scope to the given paths:
    :DiffviewOpen HEAD~2 -- lua/diffview plugin

    " Hide untracked files:
    :DiffviewOpen -uno
]]
                require("utils").create_floating_window(example, "vim", 80, 40)
            end,
            desc = "help",
            mode = { "n" },
        },
    },
})

wk_map({
    -- diffview history
    ["<leader>gh"] = {
        group = "  History",
        order = { "<Space>", "f", "r", "s", "m", "g", "a", "b", "B", "?" },
        ["<Space>"] = {
            function()
                local mode = vim.fn.mode()
                if mode == "n" then
                    vim.cmd("DiffviewFileHistory")
                else
                    vim.fn.feedkeys(":'<,'>DiffviewFileHistory", "n")
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "c", false)
                end
            end,
            desc = "normal or visual-selected",
            mode = { "n", "v" },
        },
        ["f"] = { "<cmd>DiffviewFileHistory % --follow<CR>", desc = "file", mode = { "n" } },
        ["r"] = {
            function()
                vim.fn.feedkeys(":DiffviewFileHistory --range=", "n")
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "c", false)
            end,
            desc = "range select",
            mode = { "n" },
        },
        ["s"] = { "<cmd>DiffviewFileHistory -g --range=stash<CR>", desc = "stash", mode = { "n" } },
        ["m"] = { "<cmd>DiffviewFileHistory --merges<CR>", desc = "merges", mode = { "n" } },
        ["g"] = {
            function() vim.fn.feedkeys(":DiffviewFileHistory --grep=", "n") end,
            desc = "grep",
            mode = { "n" },
        },
        ["a"] = {
            function() vim.fn.feedkeys(":DiffviewFileHistory --author=", "n") end,
            desc = "author",
            mode = { "n" },
        },
        ["b"] = { "<cmd>DiffviewFileHistory --walk-reflogs<CR>", desc = "reflog", mode = { "n" } },
        ["B"] = { "<cmd>DiffviewFileHistory --reflog<CR>", desc = "reflog all reachable", mode = { "n" } },
        ["?"] = {
            function()
                local example = [[

Examples:

    " History for the current branch:
    :DiffviewFileHistory

    " History for the current file:
    :DiffviewFileHistory %

    " History for a specific file:
    :DiffviewFileHistory path/to/some/file.txt

    " History for a specific directory:
    :DiffviewFileHistory path/to/some/directory

    " History for multiple paths:
    :DiffviewFileHistory multiple/paths foo/bar baz/qux

    " Compare history against a fixed base:
    :DiffviewFileHistory --base=HEAD~4
    :DiffviewFileHistory --base=LOCAL

    " History for a specific rev range:
    :DiffviewFileHistory --range=origin..HEAD
    :DiffviewFileHistory --range=feat/some-branch

    " Inspect diffs for Git stashes:
    :DiffviewFileHistory -g --range=stash

    " Trace the line evolution for the current visual selection:
    :'<,'>DiffviewFileHistory
]]
                require("utils").create_floating_window(example, "vim", 80, 40)
            end,
            desc = "help",
            mode = { "n" },
        },
    },
})
