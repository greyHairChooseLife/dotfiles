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

---@param include_linebreak boolean|nil 기본적으로는 줄바꿈을 다 없앤다. `string.gsub(text, "\n", "")`
---@return string|nil
M.get_visual_text = function(include_linebreak)
	vim.cmd('noau normal! "vy"')
	local text = vim.fn.getreg("v")
	vim.fn.setreg("v", {})

	if include_linebreak == false then
		-- 이게 왜 필요했던건지 모르겠지만 일단...
		text = string.gsub(text, "\n", "")
	end
	if #text > 0 then
		return text
	else
		return nil
	end
end

-- DEPRECATED:: 2025-04-13
-- M.is_buffer_active_somewhere = function(bufnr)
-- 	-- 모든 창 확인
-- 	local windows = vim.api.nvim_list_wins()
-- 	for _, winid in ipairs(windows) do
-- 		-- 각 창의 버퍼 번호 확인
-- 		if vim.api.nvim_win_get_buf(winid) == bufnr then
-- 			return true -- 버퍼가 하나 이상의 창에 활성화됨
-- 		end
-- 	end
-- 	return false -- 어떤 창에도 표시되지 않음
-- end
M.is_buffer_active_somewhere = function(bufnr)
	-- Get the current window ID
	local current_winid = vim.api.nvim_get_current_win()

	-- Check all windows
	local windows = vim.api.nvim_list_wins()
	for _, winid in ipairs(windows) do
		-- Skip the current window in our check
		if winid ~= current_winid and vim.api.nvim_win_is_valid(winid) then
			-- Check if the buffer is displayed in this other window
			if vim.api.nvim_win_get_buf(winid) == bufnr then
				return true -- Buffer is active in at least one other window
			end
		end
	end
	return false -- Buffer is not displayed in any other window
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
		{ " ", "DiagnosticsBorder" },
		{ "-", "DiagnosticsBorder" },
		{ "-", "DiagnosticsBorder" },
		{ "-", "DiagnosticsBorder" },
		{ " ", "DiagnosticsBorder" },
	},
	documentation = {
		{ "-", "BlinkCmpDocBorder" },
		{ "-", "BlinkCmpDocBorder" },
		{ "-", "BlinkCmpDocBorder" },
		{ " ", "BlinkCmpDocBorder" },
		{ "-", "BlinkCmpDocBorder" },
		{ "-", "BlinkCmpDocBorder" },
		{ "-", "BlinkCmpDocBorder" },
		{ " ", "BlinkCmpDocBorder" },
	},
	documentation_left = {
		{ "", "BlinkCmpDocBorder" },
		{ "", "BlinkCmpDocBorder" },
		{ "", "BlinkCmpDocBorder" },
		{ " ", "BlinkCmpDocBorder" },
		{ "", "BlinkCmpDocBorder" },
		{ "", "BlinkCmpDocBorder" },
		{ "", "BlinkCmpDocBorder" },
		{ "▌", "BlinkCmpDocBorder" },
	},
	signature = {
		{ "▌", "BlinkCmpSignatureHelpBorder" },
		{ " ", "BlinkCmpSignatureHelpBorder" },
		{ " ", "BlinkCmpSignatureHelpBorder" },
		{ " ", "BlinkCmpSignatureHelpBorder" },
		{ " ", "BlinkCmpSignatureHelpBorder" },
		{ " ", "BlinkCmpSignatureHelpBorder" },
		{ "▌", "BlinkCmpSignatureHelpBorder" },
		{ "▌", "BlinkCmpSignatureHelpBorder" },
	},
	git_preview = "single",
	-- git_preview = {
	-- 	{ "", "GitSignsPreviewBorder" },
	-- 	{ "", "GitSignsPreviewBorder" },
	-- 	{ "", "GitSignsPreviewBorder" },
	-- 	{ " ", "GitSignsPreviewBorder" },
	-- 	{ " ", "GitSignsPreviewBorder" },
	-- 	{ " ", "GitSignsPreviewBorder" },
	-- 	{ " ", "GitSignsPreviewBorder" },
	-- 	{ " ", "GitSignsPreviewBorder" },
	-- },
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

-- # 사용 방법
-- 하나, $HOME/.config/nvim/lua/qol/plugins.lua에서 'which-key triggers'를 찾아 prefix에 해당하는 것을 등록한다.
--   둘, 유틸 함수를 불러와 사용한다.
--
-- # 사용 예시
-- local wk_map = require("utils.wk_map")
-- wk_map({
--     ["<leader>f"] = {
--         group = "Find",
--         order = { "f", "g" }, -- 순서 정의
--         ["f"] = { "<cmd>Telescope find_files<CR>", desc = "파일 찾기", mode = "n", silent = true, buffer = 0 },
--         ["g"] = { "<cmd>Telescope live_grep<CR>", desc = "텍스트 검색", mode = "n" },
--     }
-- })
--
-- # 추가 옵션
-- :help map-arguments
--   "<buffer>", "<nowait>", "<silent>", "<script>", "<expr>" and
--   "<unique>" can be used in any order.  They must appear right after the
--   command, before any other arguments.
M.wk_map = function(mappings)
	local processed = {}
	for group_prefix, group_mappings in pairs(mappings) do
		-- Add group definition
		processed[#processed + 1] = { group_prefix, group = group_mappings.group }

		-- Create ordered mappings array
		local ordered_mappings = {}
		for key, mapping in pairs(group_mappings) do
			if key ~= "group" and key ~= "order" then
				ordered_mappings[#ordered_mappings + 1] = { key = key, mapping = mapping }
			end
		end

		-- Sort based on order if provided
		if group_mappings.order then
			local order_lookup = {}
			for i, key in ipairs(group_mappings.order) do
				order_lookup[key] = i
			end

			table.sort(ordered_mappings, function(a, b)
				local a_order = order_lookup[a.key] or 999
				local b_order = order_lookup[b.key] or 999
				return a_order < b_order
			end)
		end

		-- Process each mapping in order
		for _, item in ipairs(ordered_mappings) do
			local map = vim.deepcopy(item.mapping)
			processed[#processed + 1] = {
				group_prefix .. item.key,
				map[1],
				desc = "➜ " .. map.desc,
				mode = map.mode,
				silent = map.silent == nil and true or map.silent,
				buffer = map.buffer == nil and false or map.buffer,
				noremap = true,
			}
		end
	end
	require("which-key").add(processed)
end

local saved_cursor = nil -- 커서 위치 및 윈도우 저장 변수

-- 현재 커서 위치와 윈도우 저장
M.save_cursor_position = function()
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_win_get_buf(win)
	local row, col = unpack(vim.api.nvim_win_get_cursor(win))
	saved_cursor = { win = win, buf = buf, row = row, col = col }
	-- print("Cursor position saved: Window " .. win .. ", Buffer " .. buf .. ", Line " .. row .. ", Column " .. col)
end

-- 저장된 위치로 이동
M.restore_cursor_position = function()
	if saved_cursor then
		-- 윈도우가 여전히 유효한지 확인
		if vim.api.nvim_win_is_valid(saved_cursor.win) then
			-- 먼저 해당 윈도우로 이동
			vim.api.nvim_set_current_win(saved_cursor.win)

			-- 버퍼가 변경되었는지 확인
			local current_buf = vim.api.nvim_win_get_buf(saved_cursor.win)
			if current_buf == saved_cursor.buf then
				-- 저장된 커서 위치로 이동
				vim.api.nvim_win_set_cursor(saved_cursor.win, { saved_cursor.row, saved_cursor.col })
				-- print("Cursor position restored to Window " .. saved_cursor.win)
			else
				print("Buffer has changed in the target window")
			end
		else
			print("Saved window is no longer valid")
		end
	else
		print("No saved cursor position")
	end
end

M.is_filetype_open = function(filetype)
	-- Get all windows in current tab
	local wins = vim.api.nvim_tabpage_list_wins(0)

	-- Check each window's buffer filetype
	for _, win in ipairs(wins) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
		if ft == filetype then
			return true
		end
	end

	return false
end

-- 사용법: local win, restore = get_window_preserver()
M.get_window_preserver = function()
	local win = vim.api.nvim_get_current_win()
	local function restore()
		vim.defer_fn(function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_set_current_win(win)
			end
		end, 1)
	end
	return win, restore
end

M.get_project_name_by_cwd = function()
	local project_directory, err = vim.uv.cwd()
	if project_directory == nil then
		vim.notify(err or "Unknown error getting current directory", vim.log.levels.WARN)
		return nil
	end

	local project_name = vim.fs.basename(project_directory)
	if project_name == nil then
		vim.notify("Unable to get the project name", vim.log.levels.WARN)
		return nil
	end

	return project_name
end

---Gets the project name by finding the git root directory
---@class GetProjectNameByGitOpts
---@field print_errors? boolean Whether to print errors (defaults to true)
---@param opts? GetProjectNameByGitOpts Optional configuration table
---@return string|nil project_name Returns the project name or nil if not found
M.get_project_name_by_git = function(opts)
	opts = opts or {}
	local print_errors = opts.print_errors ~= false

	local result = vim.system({
		"git",
		"rev-parse",
		"--show-toplevel",
	}, {
		text = true,
	}):wait()

	if result.stderr ~= "" then
		if print_errors then
			vim.notify(result.stderr, vim.log.levels.WARN)
		end
		return nil
	end

	local project_directory = result.stdout:gsub("\n", "")

	local project_name = vim.fs.basename(project_directory)
	if project_name == nil then
		if print_errors then
			vim.notify("Unable to get the project name", vim.log.levels.WARN)
		end
		return nil
	end

	return project_name
end

--- show/hide cursor
M.cursor = {
	show = function()
		vim.cmd("hi Cursor blend=0")
		vim.cmd("set guicursor-=a:Cursor/lCursor")
	end,

	hide = function()
		vim.cmd("hi Cursor blend=100")
		vim.cmd("set guicursor+=a:Cursor/lCursor")
	end,
}

---Sets a Neovim option value with the specified scope
--->
---@param option string The option name to set
---@param value any The value to set the option to
---@param opts? table Optional settings table with scope (defaults to {scope = "local"})
M.setOpt = function(option, value, opts)
	opts = opts or { scope = "local" }
	vim.api.nvim_set_option_value(option, value, opts)
end

---Temporarily highlight a range of text in the current buffer
---@param start_line number The first line to highlight (1-indexed)
---@param end_line number The last line to highlight (1-indexed)
---@param highlight_group string|nil The highlight group to use (default: "Visual")
---@param duration_ms number|nil Duration in milliseconds before the highlight disappears (default: 100)
---@return nil
M.highlight_text_temporarily = function(start_line, end_line, highlight_group, duration_ms)
	-- Set defaults
	highlight_group = highlight_group or "Visual"
	duration_ms = duration_ms or 100

	local ns_id = vim.api.nvim_create_namespace("temp_highlight")

	-- Clear any existing highlights
	vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

	-- Highlight the specified lines
	for i = start_line, end_line do
		vim.highlight.range(0, ns_id, highlight_group, { i - 1, 0 }, { i - 1, -1 }, {})
	end

	-- Clear the highlight after the specified duration
	vim.defer_fn(function()
		vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
	end, duration_ms)
end

return M
