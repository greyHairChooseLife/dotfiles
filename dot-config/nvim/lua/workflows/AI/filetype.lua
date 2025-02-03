local opts = { noremap = true, silent = true, buffer = true }

vim.api.nvim_create_autocmd("FileType", {
	pattern = "Avante",
	callback = function()
		-- GUI
		vim.api.nvim_set_hl(0, "AvanteBufferHighlight", { bg = "#242024" })
		vim.api.nvim_set_hl(0, "AvanteBufferEOB", { fg = "#242024" })
		vim.cmd(
			"setlocal winhighlight=Normal:AvanteBufferHighlight,SignColumn:AvanteBufferHighlight,EndOfBuffer:AvanteBufferEOB"
		)

		-- KEYMAP
		vim.keymap.set({ "n", "v" }, "gq", "<cmd>AvanteToggle<cr>", opts)
		vim.keymap.set("n", "<Esc>", "", opts)
		vim.keymap.set("n", "i", "<Cmd>wincmd w | startinsert | normal l<CR>", opts)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "AvanteInput",
	callback = function()
		-- GUI
		-- vim.api.nvim_set_hl(0, "FugitiveBufferHighlight", { bg = "#242024" })
		-- vim.api.nvim_set_hl(0, "FugitiveBufferEOB", { fg = "#242024" })
		-- vim.cmd(
		-- 	"setlocal winhighlight=Normal:FugitiveBufferHighlight,SignColumn:FugitiveBufferHighlight,EndOfBuffer:FugitiveBufferEOB"
		-- )

		-- KEYMAP
		vim.keymap.set({ "n", "v" }, "gq", "<cmd>AvanteToggle<cr>", opts)
		vim.keymap.set("n", "<Esc>", "", opts)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "AvanteSelectedFiles",
	callback = function()
		-- GUI
		-- vim.api.nvim_set_hl(0, "AvanteSelectedFiles", { bg = "#ff0000" })
		-- vim.api.nvim_set_hl(0, "AvanteSelectedFilesEOB", { fg = "#ff0000" })
		-- vim.cmd(
		-- 	"setlocal winhighlight=Normal:AvanteSelectedFiles,SignColumn:AvanteSelectedFiles,EndOfBuffer:AvanteSelectedFilesEOB"
		-- )

		-- KEYMAP
		vim.keymap.set("n", "<Esc>", "", opts)
	end,
})
