-- COMMIT_EDITMSG 버퍼를 우측에 열리도록 설정
vim.api.nvim_create_autocmd("FileType", {
	pattern = "gitcommit",
	callback = function()
		vim.cmd("WinShift far_right")
		vim.api.nvim_win_set_width(0, 85)
		vim.defer_fn(function()
			vim.cmd("normal gg")
		end, 10)

		-- DEPRECATED:: 2025-04-22
		-- vim.cmd("wincmd p")
		-- local save_view = vim.fn.winsaveview()
		-- vim.cmd("WinShift up")
		-- vim.cmd("wincmd p")
		-- vim.cmd("WinShift right")
		-- vim.cmd("wincmd p")
		-- vim.fn.winrestview(save_view)
		-- vim.cmd("wincmd p")
		-- vim.cmd("normal gg")

		-- KEYMAP
		vim.keymap.set("n", "gq", function()
			vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" }) -- 현재 버퍼의 내용을 빈 문자열로 덮어씌워 커밋 메시지가 저장되지 않도록 합니다.
			vim.cmd("wq")
		end, { buffer = true })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "fugitive",
	callback = function()
		-- Keymap
		local opts = { buffer = true }

		vim.keymap.set("n", "P", ":G push", opts)
		vim.keymap.set("n", "F", "<Cmd>G fetch<CR>", opts)
		vim.keymap.set("n", ",g", function()
			vim.cmd("q")
			if require("utils").tree:is_visible() then
				ReloadLayout()
			end
		end, opts) -- close buffer, saving memory
		vim.keymap.set("n", "gq", function()
			vim.cmd("q")
			if require("utils").tree:is_visible() then
				ReloadLayout()
			end
		end, opts) -- close buffer, saving memory
		vim.keymap.set("n", "i", function()
			vim.cmd("normal =")
		end, opts) -- do nothing
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "DiffviewFiles",
	callback = function()
		-- gui
		local tabnr = vim.fn.tabpagenr()
		vim.fn.settabvar(tabnr, "tabname", " File")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "DiffviewFileHistory",
	callback = function()
		-- gui
		local tabnr = vim.fn.tabpagenr()
		vim.fn.settabvar(tabnr, "tabname", " Commit")
	end,
})
