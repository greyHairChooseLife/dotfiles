local map = vim.keymap.set
local opt = { noremap = true, silent = true }

---------------------------------------------------------------------------------------------------------------------------------- BUFFER
-- Navigation (next/prev)
map("n", "<Tab>", function()
    -- 	NavBuffAfterCleaning("next")
    NavBuffAfterCleaningExceptCurrentTabShowing("next")
end, opt)
map("n", "<S-Tab>", function()
    -- NavBuffAfterCleaning("prev")
    NavBuffAfterCleaningExceptCurrentTabShowing("prev")
end, opt)
map("n", "g<Tab>", BufferNextDropLast)
map("n", "<C-i>", "<C-i>", opt)

-- Quit
map({ "n", "i" }, "<leader>Q", "<cmd>qa!<CR>")
map("n", "qq", "<cmd>q<CR>") -- 버퍼를 남겨둘 필요가 있는 경우가 오히려 더 적다. 희안하게 !를 붙이면 hidden이 아니라 active상태다.
map("n", "gq", ManageBuffer_gq)
map("n", "gQ", ManageBuffer_gQ)
map("n", "gtq", ManageBuffer_gtq)
map("n", "gtQ", ManageBuffer_gtQ)
-- Save
map("n", "gw", function()
    vim.cmd("silent w")
    vim.notify("Saved current buffers", 2, { render = "minimal" })
end)
map("n", "gW", function()
    vim.cmd("wa")
    vim.notify("Saved all buffers", 2, { render = "minimal" })
end)
-- Save & Quit
map("n", "ge", ManageBuffer_ge)
map("n", "gE", ManageBuffer_gE)
-- Etc
map({ "n", "v" }, "<A-Enter><Space>", function()
    local utils = require("utils")
    local is_tree_visible = utils.tree:is_visible()

    CloseOtherBuffersInCurrentTab()

    if is_tree_visible then utils.tree:open() end
end)
map({ "n", "v" }, "<A-Enter><A-Enter>", function()
    -- it will not close nvim-tree
    Close_all_hidden_buffers()
    vim.notify("Clear all hidden buffers", 2, { render = "minimal" })
end)
map({ "n", "v" }, "<A-Enter><Enter>", function()
    -- it will not close nvim-tree
    Close_all_hidden_buffers()
    vim.notify("Clear all hidden buffers", 2, { render = "minimal" })
end)

---------------------------------------------------------------------------------------------------------------------------------- WINDOW
-- New ( horizontal / vertical )
map("n", "<A-s>", "<cmd>rightbelow new<CR>")
map("n", "<A-v>", "<cmd>vnew<CR>")
-- Navigation
map("n", "<A-h>", "<cmd>wincmd h<CR>")
map("n", "<A-j>", "<cmd>wincmd j<CR>")
map("n", "<A-k>", "<cmd>wincmd k<CR>")
map("n", "<A-l>", "<cmd>wincmd l<CR>")
map("n", "<A-space>", FocusFloatingWindow, opt)
-- Swap Position
map("n", "<A-H>", "<Cmd>WinShift left<CR>")
map("n", "<A-J>", "<Cmd>WinShift down<CR>")
map("n", "<A-K>", "<Cmd>WinShift up<CR>")
map("n", "<A-L>", "<Cmd>WinShift right<CR>")
-- Resize
map("n", "<A-Left>", "<cmd>vertical resize -2<CR>", {})
map("n", "<A-Right>", "<cmd>vertical resize +2<CR>", {})
map("n", "<A-Down>", "<cmd>horizontal resize -2<CR>", {})
map("n", "<A-Up>", "<cmd>horizontal resize +2<CR>", {})
map("n", "<A-S-Left>", "<cmd>vertical resize -8<CR>", {})
map("n", "<A-S-Right>", "<cmd>vertical resize +8<CR>", {})
map("n", "<A-S-Down>", "<cmd>horizontal resize -8<CR>", {})
map("n", "<A-S-Up>", "<cmd>horizontal resize +8<CR>", {})

---------------------------------------------------------------------------------------------------------------------------------- TABS
-- New / Rename / Swap Position
map("n", "<A-t>", NewTabWithPrompt)
map("n", "<A-r>", RenameCurrentTab)
map("n", "<A-S-p>", MoveTabRight)
map("n", "<A-S-o>", MoveTabLeft)

-- Navigaion
map("n", "<A-p>", "<cmd>tabnext<CR>")
map("n", "<A-o>", "gT")
map("n", "<A-1>", "1gt")
map("n", "<A-2>", "2gt")
map("n", "<A-3>", "3gt")
map("n", "<A-4>", "4gt")
map("n", "<A-5>", "5gt")
map("n", "<A-6>", "6gt")
map("n", "<A-7>", "7gt")
map("n", "<A-8>", "8gt")
map("n", "<A-9>", "9gt")
-- Etc
map({ "n", "v" }, "<A-Enter>t", TabOnlyAndCloseHiddenBuffers)

local wk_map = require("utils").wk_map
-- MEMO:: Split Buffer
local copy_buffer = require("buf_win_tab.modules.copy_buffer")
wk_map({
    [",s"] = {
        group = "  Split",
        order = { "v", "x", "t", "T" },
        ["v"] = { "<cmd>vs<CR>", desc = "vertical", mode = "n" },
        ["x"] = { "<cmd>sp | wincmd w<CR>", desc = "horizontal", mode = "n" },
        ["t"] = { SplitTabModifyTabname, desc = "tab new", mode = "n" },
        ["T"] = {
            function()
                local m = require("buf_win_tab.modules.select_tab")
                m.selectTabAndOpen()
            end,
            desc = "tab select",
            mode = "n",
        },
    },
    [",sd"] = {
        order = { "v", "x", "t", "T" },
        group = "duplicate",
        ["v"] = {
            function()
                local startLine, endLine
                if vim.fn.mode() ~= "n" then
                    startLine, endLine = require("utils").get_visual_line()
                end

                copy_buffer.duplicateAndOpenTempFile({
                    direction = "right",
                    range = { startLine = startLine, endLine = endLine },
                })
            end,
            desc = "virtical",
            mode = { "n", "v" },
        },
        ["x"] = {
            function()
                local startLine, endLine
                if vim.fn.mode() ~= "n" then
                    startLine, endLine = require("utils").get_visual_line()
                end

                copy_buffer.duplicateAndOpenTempFile({
                    direction = "down",
                    range = { startLine = startLine, endLine = endLine },
                })
            end,
            desc = "horizontal",
            mode = { "n", "v" },
        },
        ["t"] = {
            function()
                local startLine, endLine
                if vim.fn.mode() ~= "n" then
                    startLine, endLine = require("utils").get_visual_line()
                end

                copy_buffer.duplicateAndOpenTempFile({
                    direction = "tab",
                    range = { startLine = startLine, endLine = endLine },
                })
            end,
            desc = "tab new",
            mode = { "n", "v" },
        },
        ["T"] = {
            function()
                local startLine, endLine
                if vim.fn.mode() ~= "n" then
                    startLine, endLine = require("utils").get_visual_line()
                end

                copy_buffer.duplicateAndOpenTempFile({
                    direction = "select_tab",
                    range = { startLine = startLine, endLine = endLine },
                })
            end,
            desc = "tab select",
            mode = { "n", "v" },
        },
    },
})

-- MEMO:: Move Buffer
wk_map({
    [",m"] = {
        group = "  Move",
        order = { "t", "T" },
        ["t"] = { MoveTabModifyTabname, desc = "tab new", mode = "n" },
        ["T"] = {
            function()
                local m = require("buf_win_tab.modules.select_tab")
                m.selectTabAndOpen({ quit_current_window = true })
            end,
            desc = "tab select",
            mode = "n",
        },
    },
})

-- MEMO:: Diff
wk_map({
    [",d"] = {
        group = "󰕚  Diff",
        order = { "g", "c", "t", "f" },
        ["g"] = {
            function() VDiffSplitOnTab() end,
            desc = "git diff",
            mode = "n",
        },
        ["f"] = {
            function() vim.fn.feedkeys(":vert diffsplit ", "n") end,
            desc = "file diff",
            mode = "n",
        },
        ["t"] = {
            function()
                local tabnr = vim.fn.tabpagenr()
                vim.fn.settabvar(tabnr, "tabname", "Diff") -- GV에 탭이름 변경
                vim.cmd("wincmd h")
                vim.cmd("diffthis")
                vim.cmd("wincmd l")
                vim.cmd("diffthis")
            end,
            desc = "tab (buffers) diff",
            mode = "n",
        },
        ["c"] = {
            function()
                vim.cmd("Gitsigns toggle_word_diff")
                vim.cmd("Gitsigns toggle_linehl")
            end,
            desc = "current inline diff",
            mode = "n",
        },
    },
})
