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

vim.api.nvim_create_autocmd({ "VimResized" }, {
	callback = function()
		-- MEMO:: 현재의 fix를 해둬도, vim process의 gui 자체가 작아져버리면 해당 사이즈로 고정되어버린다.
		-- edge.nvim 이었나? 장기적으로는 거기로 옮겨가는게 좋을듯
		ReloadLayout()
	end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
	callback = function()
		-- Get/Check the command that was just executed
		local cmd = vim.fn.getcmdline()
		if cmd == "messages" then
			vim.defer_fn(function()
				if vim.bo.filetype == "noice" then
					local setOpt = utils.setOpt
					setOpt("winhighlight", "Normal:CodeCompanionNormal,EndOfBuffer:CodeCompanionEOB")
					setOpt("number", true)
					setOpt("relativenumber", true)
					setOpt("signcolumn", "no")
				end
			end, 100)
		end
	end,
})
