local opts = { noremap = true, silent = true, buffer = true }

vim.api.nvim_create_autocmd("FileType", {
	pattern = "Avante",
	callback = function()
		-- KEYMAP
		vim.keymap.set({ "n", "v" }, "gq", "<cmd>AvanteToggle<cr>", opts)
		vim.keymap.set("n", "<Esc>", "", opts)
		vim.keymap.set("n", "i", "<Cmd>wincmd j | wincmd j | wincmd j | startinsert | normal l<CR>", opts)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "AvanteInput",
	callback = function()
		-- KEYMAP
		vim.keymap.set({ "n", "v" }, "gq", "<cmd>AvanteToggle<cr>", opts)
		vim.keymap.set("n", "<Esc>", "", opts)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "AvanteSelectedFiles",
	callback = function()
		-- KEYMAP
		vim.keymap.set("n", "<Esc>", "", opts)
		vim.keymap.set("n", "i", "<Cmd>wincmd j | wincmd j | wincmd j | startinsert | normal l<CR>", opts)
	end,
})
