-- Global variables
vim.g.mapleader = "\\" -- Set leader key

-- specs table
local workflows = {
	"qol",
	"fuzzy_find",
	"file_tree",
	"builtin_terminal",
	"buf_win_tab",
	"git_diff",
	"syntax",
	"LSP",
	"format_lint",
	"auto_completion",
	"AI",
	"testing",
	"UI",
	"note_taking",
	"my_own",
	"big_data",
}
local specs = {}
for _, workflow in ipairs(workflows) do
	-- 워크플로우별 플러그인 사양을 import
	local base_path = ""
	if workflow ~= "qol" then
		base_path = "workflows."
	end
	table.insert(specs, { import = base_path .. workflow .. ".plugins" })
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = specs, -- 워크플로우별 플러그인 병합
	defaults = {
		lazy = true, -- 기본적으로 모든 플러그인을 지연 로드
	},
	git = {
		log = { "-200" }, -- (L)og에서 몇개나 보여줄지
	},
	diff = {
		cmd = "diffview.nvim",
	},
	change_detection = {
		-- automatically check for config file changes and reload the ui
		enabled = false,
		notify = true, -- get a notification when changes are found
	},
	performance = {
		rtp = {
			disabled_plugins = { -- 기본 플러그인
				"netrw",
				"netrwPlugin",
				"gzip",
				"zipPlugin",
				"tutor",
			},
		},
	},
	ui = {
		custom_keys = {
			["<localleader>i"] = false,
			["<localleader>l"] = false,
			["ya"] = {
				function(plugin)
					vim.fn.setreg("+", plugin.dir)
					vim.notify("Copied plugin directory to clipboard: " .. plugin.dir)
				end,
				desc = "copy plugin path",
			},
			["<localleader>t"] = {
				function(plugin)
					require("lazy.util").float_term(nil, {
						cwd = plugin.dir,
					})
				end,
				desc = "Open terminal in plugin dir",
			},
		},
	},
})

-- 워크플로우별 추가 설정 적용
for _, workflow in ipairs(workflows) do
	local base_path = workflow == "qol" and workflow or "workflows." .. workflow
	local config_dir = vim.fn.stdpath("config") .. "/lua/" .. base_path:gsub("%.", "/")

	-- Function to load modules from directory and its subdirectories
	local function load_directory(dir_path, module_prefix)
		-- 디렉토리 내의 모든 .lua 파일을 찾아서 로드
		if vim.fn.isdirectory(dir_path) == 1 then
			-- Load .lua files in the current directory
			local files = vim.fn.glob(dir_path .. "/*.lua")
			for file in string.gmatch(files, "[^\n]+") do
				-- plugins.lua는 이미 lazy.nvim에서 로드했으므로 제외
				if not file:match("plugins.lua$") then
					local module_name = vim.fn.fnamemodify(file, ":t:r") -- 파일 확장자 제거
					require("utils").safe_require(module_prefix .. "." .. module_name)
				end
			end

			-- Find and process subdirectories
			local subdirs = vim.fn.glob(dir_path .. "/*/")
			for subdir in string.gmatch(subdirs, "[^\n]+") do
				local subdir_name = vim.fn.fnamemodify(subdir:sub(1, -2), ":t") -- Remove trailing slash and get dir name

				-- Always load 'function' directories first
				if subdir_name == "function" then
					local subdir_module_prefix = module_prefix .. "." .. subdir_name
					print("function loaded " .. subdir_module_prefix)
					load_directory(subdir, subdir_module_prefix)
				end
			end

			-- Process other subdirectories (non-function ones)
			for subdir in string.gmatch(subdirs, "[^\n]+") do
				local subdir_name = vim.fn.fnamemodify(subdir:sub(1, -2), ":t") -- Remove trailing slash and get dir name
				if subdir_name ~= "function" then
					local subdir_module_prefix = module_prefix .. "." .. subdir_name
					print("else loaded " .. subdir_module_prefix)
					load_directory(subdir, subdir_module_prefix)
				end
			end
		end
	end

	-- Start loading from the workflow directory
	load_directory(config_dir, base_path)
end
