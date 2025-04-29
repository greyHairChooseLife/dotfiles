vim.api.nvim_create_autocmd("BufUnload", {
	pattern = "COMMIT_EDITMSG",
	group = vim.api.nvim_create_augroup("GitCommitCursorPosition", { clear = true }),
	callback = function()
		vim.defer_fn(function()
			require("utils").restore_cursor_position(true)
		end, 1)
	end,
})
