local M = {}
local utils = require("utils")

local function fixWindowSize()
	vim.cmd("set winfixwidth winfixheight")
end

local function unfixWindowSize()
	vim.cmd("set nowinfixwidth nowinfixheight")
end

M.toggleWinFix = function()
	if vim.wo.winfixwidth and vim.wo.winfixheight then
		unfixWindowSize()
	else
		fixWindowSize()
	end
end

M.toggleAllWinFix = function() -- 하나라도 not-fixed 상태라면 모두 all-fix
	local _, restore = utils.get_window_preserver()
	local all_fixed = true

	-- 모든 창의 현재 상태 확인
	for i = 1, vim.fn.winnr("$") do
		vim.cmd(i .. "wincmd w")
		if not vim.wo.winfixwidth or not vim.wo.winfixheight then
			all_fixed = false
			break
		end
	end

	-- 모든 창의 상태 변경
	for i = 1, vim.fn.winnr("$") do
		vim.cmd(i .. "wincmd w")
		if all_fixed then
			unfixWindowSize()
		else
			fixWindowSize()
		end
	end

	if all_fixed then
		vim.notify("All windows fix disabled")
	else
		vim.notify("All windows fix enabled")
	end

	restore()
end

M.unfixAllWindows = function()
	local _, restore = utils.get_window_preserver()

	-- 모든 창의 상태를 unfixed로 변경
	for i = 1, vim.fn.winnr("$") do
		vim.cmd(i .. "wincmd w")
		unfixWindowSize()
	end

	vim.notify("All windows unfixed")
	restore()
end

return M
