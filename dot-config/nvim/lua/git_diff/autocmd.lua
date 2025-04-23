-- Create autocommand group for gitcommit cursor position handling
local gitcommit_cursor_group = vim.api.nvim_create_augroup("GitCommitCursorPosition", { clear = true })

-- Save cursor position before entering gitcommit buffer
vim.api.nvim_create_autocmd("BufReadPre", {
	pattern = "COMMIT_EDITMSG", -- This is the actual file for git commits
	group = gitcommit_cursor_group,
	callback = function()
		require("utils").save_cursor_position()
		vim.notify("saved!")
	end,
})

-- Restore cursor position after leaving gitcommit buffer
vim.api.nvim_create_autocmd("BufDelete", {
	pattern = "COMMIT_EDITMSG",
	group = gitcommit_cursor_group,
	callback = function()
		require("utils").restore_cursor_position()
		vim.notify("restored!")
	end,
})
