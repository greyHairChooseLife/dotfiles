local g_utils = require("utils")

-- revoke hiding cursor
-- (while hiding is done each)
vim.api.nvim_create_autocmd("BufLeave", {
	pattern = "*",
	callback = function()
		local bufnr = vim.fn.bufnr("%")
		local ft_for_showing_cursor = { "aerial", "NvimTree", "DiffviewFiles", "DiffviewFileHistory" }
		if vim.tbl_contains(ft_for_showing_cursor, vim.bo[bufnr].filetype) then
			g_utils.cursor.show()
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
					local setOpt = g_utils.setOpt
					setOpt("winhighlight", "Normal:CodeCompanionNormal,EndOfBuffer:CodeCompanionEOB")
					setOpt("number", true)
					setOpt("relativenumber", true)
					setOpt("signcolumn", "no")
				end
			end, 100)
		end
	end,
})

-- vim.api.nvim_create_autocmd("BufEnter", {
-- 	pattern = "*",
-- 	callback = function()
-- 		local tabid = vim.api.nvim_get_current_tabpage()
-- 		local tab_wins = vim.api.nvim_tabpage_list_wins(tabid)
-- 		local nbr_notify_wins = 0
-- 		-- exclude floating window to exclude notify windows
-- 		for _, win in ipairs(tab_wins) do
-- 			if vim.api.nvim_win_get_config(win).relative ~= "" then
-- 				nbr_notify_wins = nbr_notify_wins + 1
-- 			end
-- 		end

-- 		if (#tab_wins - nbr_notify_wins) == 2 and g_utils.is_filetype_open("NvimTree", tabid) then
-- 			NvimTreeResetUI()
-- 		end
-- 	end,
-- })
