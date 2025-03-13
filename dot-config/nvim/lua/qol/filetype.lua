vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		-- keymap
		vim.keymap.set("n", "dd", QF_RemoveItem, { buffer = true, silent = true })
		vim.keymap.set("n", "DD", QF_ClearList, { buffer = true, silent = true })
		vim.keymap.set({ "n", "v" }, "<C-n>", QF_MoveNext, { buffer = true })
		vim.keymap.set({ "n", "v" }, "<C-p>", QF_MovePrev, { buffer = true })
		vim.keymap.set({ "n", "v" }, "gq", function()
			vim.cmd("q | wincmd p")
			BlinkCursorLine(500)
		end, { buffer = true, silent = true })
	end,
})

vim.api.nvim_create_augroup("GV", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "GV",
	pattern = "GV",
	callback = function()
		local tabnr = vim.fn.tabpagenr()
		vim.fn.settabvar(tabnr, "tabname", "GV") -- GV에 탭이름 변경
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt.tabstop = 2 -- 탭을 2칸으로 설정
		vim.opt.shiftwidth = 2 -- 자동 들여쓰기 2칸
		vim.opt.softtabstop = 2 -- 백스페이스로 2칸씩 지우기
		vim.opt.expandtab = true -- 탭을 공백으로 변환
	end,
})
