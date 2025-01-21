vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		-- gui
		vim.api.nvim_command("wincmd L")
		vim.api.nvim_win_set_width(0, 100)
		vim.api.nvim_set_hl(0, "QFBufferBG", { bg = "#201010" })
		vim.api.nvim_set_hl(0, "QFBufferEOB", { fg = "#201010" })
		vim.cmd("setlocal winhighlight=Normal:QFBufferBG,EndOfBuffer:QFBufferEOB")

		-- keymap
		vim.keymap.set("n", "dd", QF_RemoveItem, { buffer = true, silent = true })
		vim.keymap.set("n", "DD", QF_ClearList, { buffer = true, silent = true })
		vim.keymap.set({ "n", "v" }, "<C-n>", QF_MoveNext, { buffer = true })
		vim.keymap.set({ "n", "v" }, "<C-p>", QF_MovePrev, { buffer = true })
		vim.keymap.set({ "n", "v" }, "gq", function()
			vim.cmd("q | wincmd p")
			BlinkCursorLine(500)
		end, { buffer = true, silent = true })
	end,
})

vim.api.nvim_create_augroup("GV", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "GV",
	pattern = "GV",
	callback = function()
		local tabnr = vim.fn.tabpagenr()
		vim.fn.settabvar(tabnr, "tabname", "GV") -- GV에 탭이름 변경
	end,
})
