local utils = require("utils")
local setOpt = utils.setOpt

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
		-- setOpt("winhighlight", "FoldColumn:MDFoldColumn")
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
		setOpt("foldcolumn", "5")
		setOpt("textwidth", 100)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "aerial",
	callback = function()
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
	pattern = { "DiffviewFiles", "DiffviewFileHistory" },
	callback = function()
		-- options
		vim.defer_fn(function()
			setOpt(
				"winhighlight",
				"Normal:FugitiveNormal,EndOfBuffer:FugitiveEOB,FoldColumn:FugitiveFoldColumn,SignColumn:FugitiveFoldColumn,CursorLine:DiffviewCursorLine"
			)
		end, 1)
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

vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "*",
	callback = function()
		if vim.bo.filetype == "codecompanion" then
			setOpt(
				"winhighlight",
				"Normal:CodeCompanionNormal,"
					.. "SignColumn:CodeCompanionSignColumn,"
					.. "EndOfBuffer:CodeCompanionEOB,"
					.. "Folded:CodeCompanionFolded"
			)

			vim.opt_local.foldmethod = "expr"
			vim.opt_local.foldenable = true
			vim.opt_local.foldtext = "v:lua.codecompanion_fold_text(v:foldstart, v:foldend, v:foldlevel)"
			vim.opt_local.foldexpr = "v:lua.codecompanion_fold_expr(v:lnum)"
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "terminal",
	callback = function()
		-- options
		setOpt(
			"winhighlight",
			"Normal:TerminalNormal,FoldColumn:TerminalSignColumn,SignColumn:TerminalSignColumn,EndOfBuffer:TerminalEOB"
		)
	end,
})
