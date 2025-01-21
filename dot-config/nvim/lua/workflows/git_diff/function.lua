function VDiffSplitOnTab()
	vim.cmd("sp | wincmd T | Gvdiffsplit | wincmd l")

	local tabnr = vim.fn.tabpagenr()
	vim.fn.settabvar(tabnr, "tabname", "Diff")
end

function DiffviewOpenWithVisualHash()
	local hash = require("utils").get_visual_text()
	vim.cmd("DiffviewOpen " .. hash .. "^.." .. hash)
end

function Visual_stage()
	local first_line = vim.fn.line("v")
	local last_line = vim.fn.getpos(".")[2]
	require("gitsigns").stage_hunk({ first_line, last_line })
	-- Switch back to normal mode, there may be a cleaner way to do this
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "t", false)
end

function Visual_undo_stage()
	local first_line = vim.fn.line("v")
	local last_line = vim.fn.getpos(".")[2]
	-- TODO:: undo_stage_hunk는 depreacted라 고하는데, 막상 안내하듯 바꿔보면 안되는데?
	-- https://github.com/lewis6991/gitsigns.nvim/commit/8b74e56
	-- require("gitsigns").stage_hunk({ first_line, last_line })
	require("gitsigns").undo_stage_hunk({ first_line, last_line })

	-- Switch back to normal mode, there may be a cleaner way to do this
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "t", false)
end

function Visual_reset()
	local first_line = vim.fn.line("v")
	local last_line = vim.fn.getpos(".")[2]
	require("gitsigns").reset_hunk({ first_line, last_line })
	-- Switch back to normal mode, there may be a cleaner way to do this
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "t", false)
end
