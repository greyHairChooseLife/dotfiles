local M = {}

M.safe_require = function(module)
	local ok, _ = pcall(require, module)
	-- if not ok then
	--     vim.notify("Module " .. module .. " not found", vim.log.levels.WARN)
	-- end
end

M.auto_mkdir = function()
	local dir = vim.fn.expand("<afile>:p:h")

	-- This handles URLs using netrw. See ':help netrw-transparent' for details.
	if dir:find("%l+://") == 1 then
		return
	end

	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end
end

M.url_encode = function(str)
	if str then
		str = string.gsub(str, "\n", "\r\n")
		str = string.gsub(str, "([^%w %-%_%.%~])", function(c)
			return string.format("%%%02X", string.byte(c))
		end)
		str = string.gsub(str, " ", "+")
	end
	return str
end

M.get_visual_text = function()
	vim.cmd('noau normal! "vy"')
	local text = vim.fn.getreg("v")
	vim.fn.setreg("v", {})

	text = string.gsub(text, "\n", "")
	if #text > 0 then
		return text
	else
		return ""
	end
end

M.is_buffer_active_somewhere = function(bufnr)
	-- 모든 창 확인
	local windows = vim.api.nvim_list_wins()
	for _, winid in ipairs(windows) do
		-- 각 창의 버퍼 번호 확인
		if vim.api.nvim_win_get_buf(winid) == bufnr then
			return true -- 버퍼가 하나 이상의 창에 활성화됨
		end
	end
	return false -- 어떤 창에도 표시되지 않음
end

M.close_empty_unnamed_buffers = function()
	-- 현재 모든 윈도우에 로드된 활성 버퍼 목록 가져오기
	local active_buffers = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		active_buffers[buf] = true
	end

	-- 모든 버퍼를 확인하면서, 비어있고 이름이 없는 비활성 버퍼를 닫기
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == "" and not active_buffers[buf] then
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			if #lines == 0 or (#lines == 1 and lines[1] == "") then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end
	end
end

M.get_current_tabname = function()
	local tabnr = vim.fn.tabpagenr()
	return vim.fn.gettabvar(tabnr, "tabname", "No Name")
end

-- 밀리초 아니고 그냥 초
M.print_in_time = function(msg, time)
	-- message history에는 남기지 않는다.
	vim.api.nvim_echo({ { msg } }, false, {})

	-- vim.defer_fn(function()
	--   vim.api.nvim_echo({{''}}, false, {})  -- 빈 문자열로 메시지 지우기
	-- end, time * 1000)
	-- 성능 이슈가 있어 아래를 사용한다.
	local timer = vim.loop.new_timer()
	timer:start(
		time * 1000,
		0,
		vim.schedule_wrap(function()
			vim.api.nvim_echo({ { "" } }, false, {}) -- 빈 문자열로 메시지 지우기
			timer:stop()
			timer:close()
		end)
	)
end

M.tree = {
	api = require("nvim-tree.api"),
	is_visible = function(self)
		return self.api.tree.is_visible()
	end,
	open = function(self)
		local tree_api = self.api.tree

		tree_api.toggle({ find_files = true, focus = false })
		if self:is_visible() then
			ShowCursor()
		end
	end,
}

M.close_FT_buffers = function(FT)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			-- local filetype = vim.api.nvim_buf_get_option(buf, "filetype") -- deprecated
			local filetype = vim.api.nvim_get_option_value("filetype", { scope = "local" })
			if filetype == FT then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end
	end
end

M.borders = {
	diagnostics = {
		{ "-", "DiagnosticsBorder" },
		{ "-", "DiagnosticsBorder" },
		{ "-", "DiagnosticsBorder" },
		" ",
		{ "-", "DiagnosticsBorder" },
		{ "-", "DiagnosticsBorder" },
		{ "-", "DiagnosticsBorder" },
		" ",
	},
	documentation = {
		{ "-", "BlinkCmpDocBorder" },
		{ "-", "BlinkCmpDocBorder" },
		{ "-", "BlinkCmpDocBorder" },
		" ",
		{ "-", "BlinkCmpDocBorder" },
		{ "-", "BlinkCmpDocBorder" },
		{ "-", "BlinkCmpDocBorder" },
		" ",
	},
	full = {
		"▄",
		"▄",
		"▄",
		"█",
		"▀",
		"▀",
		"▀",
		"█",
	},
}

M.icons = {
	diagnostics = {
		Error = " ",
		Warn = " ",
		Hint = " ",
		Info = " ",
	},
	git = {
		Add = "+",
		Change = "~",
		Delete = "-",
	},
	kinds = {
		Array = "󰅪",
		Branch = "",
		Boolean = "󰨙",
		Class = "󰠱",
		Color = "󰏘",
		Constant = "󰏿",
		Constructor = "",
		Enum = "",
		EnumMember = "",
		Event = "",
		Field = "",
		File = "",
		Folder = "󰉋",
		Function = "󰊕",
		Interface = "",
		Key = "",
		Keyword = "󰌋",
		Method = "󰆧",
		Module = "󰏗 ",
		Namespace = "󰅩",
		Number = "󰎠",
		Null = "",
		Object = "",
		Operator = "+",
		Package = "",
		Property = "󰜢",
		Reference = "",
		Snippet = "",
		String = "𝓐",
		Struct = "󰙅",
		Text = "",
		TypeParameter = "󰆩",
		Unit = "",
		Value = "󰎠",
		Variable = "󰀫",
	},
	cmp_sources = {
		LSP = "✨",
		Luasnip = "🚀",
		Buffer = "📝",
		Path = "📁",
		Cmdline = "💻",
	},
	statusline = {
		Error = " ",
		Warn = " ",
		Hint = " ",
		Info = " ",
	},
}

return M
