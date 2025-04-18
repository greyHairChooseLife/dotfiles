local map = vim.keymap.set
local opt = { noremap = true, silent = true }

---------------------------------------------------------------------------------------------------------------------------------- BUFFER
-- Navigation (next/prev)
map("n", "<Tab>", function()
	NavBuffAfterCleaning("next")
end, opt)
map("n", "<S-Tab>", function()
	NavBuffAfterCleaning("prev")
end, opt)
map("n", "<C-i>", "<C-i>", opt)
-- Quit
map({ "n", "i" }, "<leader>Q", "<cmd>qa!<CR>")
map("n", "qq", "<cmd>q<CR>") -- 버퍼를 남겨둘 필요가 있는 경우가 오히려 더 적다. 희안하게 !를 붙이면 hidden이 아니라 active상태다.
map("n", "gq", ManageBuffer_gq)
map("n", "gQ", ManageBuffer_gQ)
map("n", "g<Tab>", BufferNextDropLast)
map("n", "gtq", ManageBuffer_gtq)
map("n", "gtQ", ManageBuffer_gtQ)
-- Save
map("n", "gw", function()
	vim.cmd("silent w")
	vim.notify("Saved current buffers", 3, { render = "minimal" })
end)
map("n", "gW", function()
	vim.cmd("wa")
	vim.notify("Saved all buffers", 3, { render = "minimal" })
end)
-- Save & Quit
map("n", "ge", ManageBuffer_ge)
map("n", "gE", ManageBuffer_gE)
-- Etc
map({ "n", "v" }, "<A-Enter><Space>", function()
	local utils = require("utils")
	local is_tree_visible = utils.tree:is_visible()

	CloseOtherBuffersInCurrentTab()

	if is_tree_visible then
		utils.tree:open()
	end
end)

---------------------------------------------------------------------------------------------------------------------------------- WINDOW
-- New ( horizontal / vertical )
map("n", "<A-x>", "<cmd>rightbelow new<CR>")
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
wk_map({
	[",m"] = {
		group = "  Move",
		["t"] = { MoveTabModifyTabname, desc = "tab new", mode = "n" },
	},
})

-- MEMO:: Split Buffer
local copy_buffer = require("workflows.buf_win_tab.modules.copy_buffer")
wk_map({
	[",s"] = {
		group = "  Split",
		order = { "v", "d", "x", "t" },
		["v"] = { "<cmd>vs<CR>", desc = "vertical", mode = "n" },
		["x"] = { "<cmd>sp | wincmd w<CR>", desc = "horizontal", mode = "n" },
		["t"] = { SplitTabModifyTabname, desc = "new tab", mode = "n" },
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

-- MEMO:: Diff
wk_map({
	[",d"] = {
		group = "󰕚  Diff",
		order = { "g", "f" },
		["g"] = { VDiffSplitOnTab, desc = "git diff", mode = "n" },
		["f"] = {
			function()
				vim.fn.feedkeys(":vert diffsplit ", "n")
			end,
			desc = "file diff",
			mode = "n",
		},
	},
})
