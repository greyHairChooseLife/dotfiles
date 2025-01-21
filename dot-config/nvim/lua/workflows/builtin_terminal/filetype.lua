vim.api.nvim_create_autocmd("FileType", {
	pattern = "toggleterm",
	callback = function()
		-- gui
		vim.api.nvim_set_hl(0, "TermBufferHighlight", { bg = "#0c0c0c" })
		vim.api.nvim_set_hl(0, "TermBufferEOB", { fg = "#0c0c0c" })
		vim.cmd(
			"setlocal winhighlight=Normal:TermBufferHighlight,SignColumn:TermBufferHighlight,EndOfBuffer:TermBufferEOB"
		)

		-- keymap
		vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { buffer = true })
		-- NEW WINDOW & TAB
		vim.keymap.set("t", "<A-x>", "<Cmd>rightbelow new<CR>", { buffer = true })
		vim.keymap.set("t", "<A-v>", "<Cmd>vnew<CR>", { buffer = true })
		vim.keymap.set("t", "<A-t>", NewTabWithPrompt, { buffer = true })
		vim.keymap.set("t", "<A-r>", RenameCurrentTab, { buffer = true })
		vim.keymap.set("t", "<A-.>", MoveTabRight, { buffer = true })
		vim.keymap.set("t", "<A-,>", MoveTabLeft, { buffer = true })
		-- FOCUS TABS
		vim.keymap.set("t", "<A-p>", [[<C-\><C-n>gt]], { noremap = true, silent = true, buffer = true })
		vim.keymap.set("t", "<A-o>", [[<C-\><C-n>gT]], { noremap = true, silent = true, buffer = true })
		for i = 1, 9 do
			-- 숫자에 따른 탭 이동 (1gt, 2gt, ..., 9gt)
			vim.keymap.set("t", "<A-" .. i .. ">", [[<C-\><C-n>]] .. i .. [[gt]], { noremap = true, silent = true })
		end
		-- FOCUS WINDOW
		vim.keymap.set("t", "<A-h>", "<Cmd>wincmd h<CR>", { buffer = true })
		vim.keymap.set("t", "<A-j>", "<Cmd>wincmd j<CR>", { buffer = true })
		vim.keymap.set("t", "<A-k>", "<Cmd>wincmd k<CR>", { buffer = true })
		vim.keymap.set("t", "<A-l>", "<Cmd>wincmd l<CR>", { buffer = true })
		-- MOVE WINDOW PtSITION
		vim.keymap.set("t", "<A-H>", "<Cmd>WinShift left<CR>", { buffer = true })
		vim.keymap.set("t", "<A-J>", "<Cmd>WinShift down<CR>", { buffer = true })
		vim.keymap.set("t", "<A-K>", "<Cmd>WinShift up<CR>", { buffer = true })
		vim.keymap.set("t", "<A-L>", "<Cmd>WinShift right<CR>", { buffer = true })
		vim.keymap.set("t", ",mt", "<C-w>T", { buffer = true }) -- move window to tab
		vim.keymap.set("t", ",st", "<Cmd>sp<CR><C-w>T", { buffer = true }) -- copy window to tab
		-- WINDOW RESIZEt
		vim.keymap.set("t", "<A-Left>", "<Cmd>vertical resize -2<CR>", { buffer = true })
		vim.keymap.set("t", "<A-Right>", "<Cmd>vertical resize +2<CR>", { buffer = true })
		vim.keymap.set("t", "<A-Down>", "<Cmd>horizontal resize -2<CR>", { buffer = true })
		vim.keymap.set("t", "<A-Up>", "<Cmd>horizontal resize +2<CR>", { buffer = true })
		-- WINDOW RESIZEtHARD
		vim.keymap.set("t", "<A-S-Left>", "<Cmd>vertical resize -8<CR>", { buffer = true })
		vim.keymap.set("t", "<A-S-Right>", "<Cmd>vertical resize +8<CR>", { buffer = true })
		vim.keymap.set("t", "<A-S-Down>", "<Cmd>horizontal resize -8<CR>", { buffer = true })
		vim.keymap.set("t", "<A-S-Up>", "<Cmd>horizontal resize +8<CR>", { buffer = true })
	end,
})
