local utils = require("utils")

-- revoke hiding cursor
-- (while hiding is done each)
vim.api.nvim_create_autocmd("BufLeave", {
	pattern = "*",
	callback = function()
		local bufnr = vim.fn.bufnr("%")
		local ft = { "NvimTree", "aerial" }

		local is_listed_ft = vim.tbl_contains(ft, vim.bo[bufnr].filetype)

		if is_listed_ft then
			utils.cursor.show()
		end
	end,
})
