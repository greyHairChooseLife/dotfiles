local g_utils = require("utils")

function VDiffSplitOnTab()
	vim.cmd("sp | wincmd T")
	vim.cmd("Gvdiffsplit")
	vim.cmd("wincmd l")

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

function Commit_with_selected()
	local commit_message = require("utils").get_visual_text(true)
	vim.fn.setreg("+", commit_message)

	vim.cmd("silent G commit")
	-- Wait briefly for the commit buffer to open, then paste the response
	vim.defer_fn(function()
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("VggP", true, false, true), "n", false)
	end, 100)
end

function OpenCommitMsg()
	g_utils.save_cursor_position(true)
	vim.cmd("G commit")
end

function AmendCommitMsg()
	g_utils.save_cursor_position(true)
	vim.cmd("G commit --amend")
end
