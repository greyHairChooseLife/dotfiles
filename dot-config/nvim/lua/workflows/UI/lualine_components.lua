-- Lualine components and configuration
local M = {}

M.colors = {
	blue = "#61afef",
	git_add = "#40cd52",
	git_change = "#ffcc00",
	git_delete = "#f1502f",
	greenbg = "#98c379",
	purple = "#c678dd",
	orange = "#FF8C00",
	wwhite = "#abb2bf",
	white = "#ffffff",
	bblack = "#282c34",
	black = "#000000",
	terminal_bg = "#0c0c0c",
	grey = "#333342",
	bg = "#24283b",
	bg2 = "#242024",
	active_qf = "#db4b4b",
	qf_bg = "#201010",
	nvimTree = "#333342",
	active_oil = "#BDB80B",
	purple1 = "#A020F0",
	red2 = "#DC143C",
	search = "#ffff00",
}

M.theme = {
	normal = {
		a = { fg = M.colors.orange, bg = M.colors.orange },
		b = { fg = M.colors.orange, bg = M.colors.bg },
		c = { fg = M.colors.black, bg = M.colors.greenbg },
		x = { fg = M.colors.black, bg = M.colors.orange },
		y = { fg = M.colors.wwhite, bg = M.colors.bg },
		z = { fg = M.colors.bg, bg = M.colors.orange },
	},
	inactive = {
		a = { fg = M.colors.orange, bg = M.colors.bg },
		b = { fg = M.colors.orange, bg = M.colors.bg },
		c = { fg = M.colors.grey, bg = M.colors.grey },
		x = { fg = M.colors.grey, bg = M.colors.grey },
		y = { fg = M.colors.grey, bg = M.colors.grey },
		z = { fg = M.colors.wwhite, bg = M.colors.grey },
	},
}

-- Helper functions for lualine components
function M.empty()
	return ""
end

function M.this_is_space()
	return " "
end

function M.search_counter()
	local sc = vim.fn.searchcount({ maxcount = 9999 })
	-- 검색이 활성화(total > 0)되어 있고 하이라이트가 켜져있을 때만 표시합니다.
	if sc.total > 0 and vim.v.hlsearch == 1 then
		return string.format("search: %d/%d", sc.current, sc.total)
	end
	return ""
end

function M.get_git_branch()
	-- 현재 디렉토리가 Git 저장소인지 확인
	local git_dir = vim.fn.finddir(".git", ".;")
	if git_dir == "" then
		return "no git" -- Git 저장소가 아니면 빈 문자열 반환
	end

	-- 현재 Git 브랜치를 가져옴
	local handle = io.popen("git branch --show-current 2>/dev/null")
	if not handle then
		return "git error"
	end

	local branch = handle:read("*a")
	if not branch then
		handle:close()
		return "git error"
	end

	handle:close()

	-- 줄바꿈 제거하고 브랜치 이름 반환
	return "branch: " .. branch:gsub("%s+", "")
end

function M.this_is_fugitive()
	return "- Fugitive -"
end

function M.harpoon_length()
	-- get the length of the harpoon list
	local items = require("harpoon"):list():length()
	if items == 0 then
		return ""
	else
		return "󰀱 " .. items
	end
end

function M.winfix_status()
	if vim.wo.winfixwidth and vim.wo.winfixheight then
		return "  Fix" -- 🔒 고정 표시
	else
		return ""
	end
end

function M.copilot_chat()
	local ft = vim.bo.filetype
	if ft ~= "copilot-chat" then
		return ""
	end

	local async = require("plenary.async")
	local chat = require("CopilotChat")
	local config = chat.config
	local model = config.model

	async.run(function()
		local resolved_model = chat.resolve_model()
		if resolved_model then
			model = resolved_model
		end
	end, function(_, _)
		-- Nothing to do here since we're just updating a local variable
	end)

	return model
end

-- Custom sections for different filetypes
M.my_terminal = {
	filetypes = { "terminal" },
	sections = {
		lualine_a = {
			{
				"filetype",
				color = { bg = M.colors.white, fg = M.colors.terminal_bg, gui = "bold,italic" },
				padding = { left = 1, right = 5 },
			},
		},
	},
	inactive_sections = {
		lualine_a = {
			{
				"filetype",
				color = { bg = M.colors.terminal_bg, fg = M.colors.white, gui = "italic" },
				padding = { left = 1, right = 5 },
			},
		},
	},
}

M.my_quickfix = {
	filetypes = { "qf" },
	sections = {
		lualine_a = {
			{
				"filetype",
				color = { bg = M.colors.active_qf, fg = M.colors.white, gui = "bold,italic" },
				padding = { left = 3, right = 5 },
			},
		},
	},
	inactive_sections = {
		lualine_a = {
			{
				"filetype",
				color = { bg = M.colors.qf_bg, fg = M.colors.white, gui = "bold,italic" },
				padding = { left = 3, right = 5 },
			},
		},
	},
}

M.my_nvimTree = {
	filetypes = { "NvimTree" },
	sections = {
		lualine_a = {
			{
				M.get_git_branch,
				color = { bg = M.colors.nvimTree, fg = M.colors.orange, gui = "bold,italic" },
				padding = { left = 3 },
			},
			{
				M.harpoon_length,
				color = { bg = M.colors.nvimTree, fg = M.colors.orange, gui = "bold,italic" },
				padding = { left = 22, right = 3 },
			},
		},
	},
	inactive_sections = {
		lualine_a = {
			{
				M.get_git_branch,
				color = { bg = M.colors.nvimTree, fg = M.colors.orange, gui = "bold,italic" },
				padding = { left = 3 },
			},
		},
		lualine_z = {
			{
				M.harpoon_length,
				color = { bg = M.colors.nvimTree, fg = M.colors.orange, gui = "bold,italic" },
				padding = { left = 22, right = 4 },
			},
		},
	},
}

M.my_fugitive = {
	filetypes = { "fugitive" },
	sections = {
		lualine_a = {
			{
				M.get_git_branch,
				color = { bg = M.colors.orange, fg = M.colors.bblack, gui = "bold" },
				padding = { left = 1, right = 5 },
			},
		},
		-- lualine_z = { { M.this_is_fugitive, color = { bg = M.colors.orange, fg = M.colors.bblack } } },
	},
	inactive_sections = {
		lualine_a = {
			{
				M.get_git_branch,
				color = { bg = M.colors.bg2, fg = M.colors.orange, gui = "bold" },
				padding = { left = 1, right = 5 },
				-- separator = { right = "" },
			},
		},
	},
}

M.my_oil = {
	filetypes = { "oil" },
	sections = {
		lualine_a = {
			{
				"filetype",
				color = { bg = M.colors.active_oil, fg = M.colors.bblack, gui = "bold,italic" },
				padding = { left = 3, right = 5 },
			},
		},
	},
	inactive_sections = {
		lualine_a = {
			{
				"filetype",
				color = { bg = M.colors.active_oil, fg = M.colors.bblack, gui = "bold,italic" },
				padding = { left = 3, right = 5 },
				-- separator = { right = " " },
			},
		},
		lualine_b = { { M.empty, color = { bg = M.colors.grey } } },
		lualine_z = { { M.this_is_space, color = { bg = M.colors.grey } } },
	},
}

M.my_copilot_chat = {
	filetypes = { "copilot-chat" },
	sections = {
		lualine_a = {
			{
				"filetype",
				color = { bg = M.colors.bg2, fg = M.colors.bg2 },
			},
		},
		lualine_z = { { M.copilot_chat, color = { fg = M.colors.orange, bg = M.colors.bg2 } } },
	},
	inactive_sections = {
		lualine_z = { { M.copilot_chat, color = { fg = M.colors.orange, bg = M.colors.bg2 } } },
	},
}

return M
