-- COMMIT_EDITMSG 버퍼를 우측에 열리도록 설정
vim.api.nvim_create_autocmd("FileType", {
	pattern = "gitcommit",
	callback = function()
		-- 시작시 윈도우를 최우측에 두고, 커서를 최상단에 위치
		vim.cmd("WinShift far_right")
		vim.api.nvim_win_set_width(0, 85)
		vim.defer_fn(function()
			vim.cmd("normal gg")
		end, 10)

		-- KEYMAP
		vim.keymap.set("n", "gq", function()
			vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" }) -- 현재 버퍼의 내용을 빈 문자열로 덮어씌워 커밋 메시지가 저장되지 않도록 합니다.
			vim.cmd("wq")
		end, { buffer = true })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "gitrebase",
	callback = function()
		vim.cmd("WinShift far_up")

		-- KEYMAP
		vim.keymap.set("n", "gq", function()
			vim.cmd("q!")
			vim.notify("Rebase Aborted!", 4, { render = "minimal" })
		end, { buffer = true })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "fugitive",
	callback = function()
		vim.defer_fn(function()
			vim.fn.feedkeys("gU", "x") -- 시작시 커서를 unstaged 목록에 위치
		end, 1)

		-- Keymap
		local opts = { buffer = true }

		vim.keymap.set("n", "cc", OpenCommitMsg, opts)
		vim.keymap.set("n", "ca", AmendCommitMsg, opts)
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
