local utils = require("utils")
local function setOpt(option, value, opts)
	opts = opts or { scope = "local" }
	vim.api.nvim_set_option_value(option, value, opts)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		-- position
		vim.api.nvim_command("wincmd L")

		-- size
		vim.api.nvim_win_set_width(0, 100)

		-- options
		setOpt("winhighlight", "Normal:QFBufferBG,EndOfBuffer:QFBufferEOB")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		-- etc
		-- vim.cmd('IBLEnable')

		-- options
		setOpt("winhighlight", "FoldColumn:MDFoldColumn")
		setOpt(
			"winhighlight",
			"Normal:NoteBackground,FloatBorder:NoteBorder,FloatTitle:NoteTitle,EndOfBuffer:NoteEOB,FoldColumn:NoteFoldColumn"
		)
		setOpt("number", false)
		setOpt("relativenumber", false)
		setOpt("signcolumn", "no")
		setOpt("foldcolumn", "2")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "vimwiki",
	callback = function()
		-- etc
		-- vim.cmd('IBLEnable')
		require("gitsigns").toggle_signs(false)
		vim.cmd("NvimTreeResize 100") -- require('nvim-tree.api').nvim-tree-api.tree.resize(100) 뭐야 외완되

		-- options
		setOpt("winhighlight", "FoldColumn:VimwikiFoldColumn")
		setOpt("number", false)
		setOpt("relativenumber", false)
		setOpt("signcolumn", "no")
		setOpt("foldcolumn", "2")
		setOpt("textwidth", 100)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "aerial",
	callback = function()
		-- etc
		utils.cursor.hide()

		-- options
		setOpt("winhighlight", "Normal:AerialNormal,EndOfBuffer:AerialEOB,FoldColumn:AerialFoldColumn")
		setOpt("signcolumn", "no")
		setOpt("foldcolumn", "2")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "gitcommit", "fugitive" },
	callback = function()
		-- options
		setOpt("winhighlight", "Normal:FugitiveNormal,EndOfBuffer:FugitiveEOB,FoldColumn:FugitiveFoldColumn")
		setOpt("number", false)
		setOpt("relativenumber", false)
		setOpt("signcolumn", "no")
		setOpt("foldcolumn", "2")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "oil",
	callback = function()
		-- options
		setOpt("winhighlight", "Normal:OilNormal,EndOfBuffer:OilEOB,SignColumn:OilSignColumn")
		-- setOpt("signcolumn", "yes")
		-- setOpt("foldcolumn", "2")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "NvimTree",
	callback = function()
		-- options
		setOpt("winhighlight", "EndOfBuffer:NvimTreeEOB")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "Avante",
	callback = function()
		-- options
		setOpt("winhighlight", "Normal:AvanteNormal,SignColumn:AvanteSignColumn,EndOfBuffer:AvanteEOB")
	end,
})

vim.api.nvim_create_autocmd("BufEnter", { -- 왠지 모르지만 BufEnter로 해야한다.
	pattern = "copilot-*",
	callback = function()
		-- options
		setOpt(
			"winhighlight",
			"Normal:ChatWithCopilotNormal,FoldColumn:ChatWithCopilotNormal,SignColumn:ChatWithCopilotNormal,StatusLineNC:ChatWithCopilotNormal,StatusLine:ChatWithCopilotNormal,EndOfBuffer:ChatWithCopilotEOB"
		)
		setOpt("number", false)
		setOpt("relativenumber", false)
		setOpt("conceallevel", 0)
		setOpt("cursorline", false)
		setOpt("signcolumn", "no")
		setOpt("statusline", "%!v:lua._G.status_line_copilot_chat()")
	end,
})
