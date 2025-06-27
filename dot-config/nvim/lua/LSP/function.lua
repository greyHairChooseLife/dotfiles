local current_line_enabled = false

---@class Opts
---@field force "on" | "off" toggle 대신 무조건 켜기
---@param opts Opts? 옵션 지정
function ToggleVirtualText(opts)
	opts = opts or {}
	local force = opts.force or false

	if force == "on" then
		current_line_enabled = true
		return vim.diagnostic.config({ virtual_lines = { current_line = true } })
	elseif force == "off" then
		current_line_enabled = false
		return vim.diagnostic.config({ virtual_lines = false })
	end

	current_line_enabled = not current_line_enabled
	vim.diagnostic.config({
		virtual_lines = current_line_enabled == true and { current_line = true } or false,
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
