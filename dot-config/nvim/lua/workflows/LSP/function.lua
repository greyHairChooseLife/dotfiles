local virtual_lines_enabled = false
local signs_enabled = true

---@class Opts
---@field force "on" | "off" toggle 대신 무조건 켜기
---@param opts Opts? 옵션 지정
function ToggleVirtualText(opts)
	opts = opts or {}
	local force = opts.force or false

	if force == "on" then
		return vim.diagnostic.config({ virtual_lines = true })
	elseif force == "off" then
		return vim.diagnostic.config({ virtual_lines = false })
	end

	virtual_lines_enabled = not virtual_lines_enabled
	signs_enabled = not signs_enabled

	vim.diagnostic.config({
		virtual_lines = virtual_lines_enabled == true and { current_line = true } or false,
	})
end

function CopyDiagnosticsAtLine()
	local pos = vim.api.nvim_win_get_cursor(0) -- 현재 커서 위치 가져오기
	local line = pos[1] - 1 -- 0-based 인덱스

	-- 현재 라인의 모든 diagnostics 가져오기
	local diagnostics = vim.diagnostic.get(0, { lnum = line })

	if #diagnostics == 0 then
		print("No diagnostics on current line")
		return nil
	end

	-- 진단 정보를 lnum, col 순서로 정렬
	table.sort(diagnostics, function(a, b)
		if a.lnum == b.lnum then
			return a.col < b.col
		end
		return a.lnum < b.lnum
	end)

	-- 모든 메시지를 한 줄씩 연결
	local messages = {}
	for _, diag in ipairs(diagnostics) do
		table.insert(messages, string.format("[%d:%d] %s", diag.lnum + 1, diag.col, diag.message))
	end
	local all_messages = table.concat(messages, "\n")

	-- 클립보드에 복사
	vim.fn.setreg("+", all_messages)
	print("Copied diagnostics for line " .. (line + 1) .. ":\n" .. all_messages)
	return all_messages
end

-- MEMO:: for keymaps
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
local T = {} -- Telescope
local tele = require("telescope.builtin")

T.diagnostic_local = function()
	tele.diagnostics({
		bufnr = 0, -- 현재 버퍼로 제한
		line_width = 200, -- 어차피 현재 파일일이다.
	})
end

T.diagnostic_global = function()
	tele.diagnostics({
		bufnr = nil, -- 모든 버퍼
		line_width = 200, --diagnostic line은 필요 없고 파일만 구분되면 돼
	})
end

return T
