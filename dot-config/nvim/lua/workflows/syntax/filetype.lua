vim.api.nvim_create_autocmd("FileType", {
	pattern = "aerial",
	callback = function()
		-- KEYMAP
		vim.keymap.set({ "n", "v" }, "gq", function()
			vim.cmd("q | wincmd p")
			BlinkCursorLine(500)
		end, { buffer = true, silent = true })
	end,
})
