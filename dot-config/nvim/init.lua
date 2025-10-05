-- Global variables
vim.g.mapleader = "\\" -- Set leader key

-- specs table
local workflows = {
	"qol",
	"picker",
	"file_tree",
	"debug",
	"builtin_terminal",
	"buf_win_tab",
	"git_diff",
	"syntax",
	"LSP",
	"format_lint",
	"completion",
	"AI",
	"UI",
	"note_taking",
	"big_data",
}
local specs = {}
for _, workflow in ipairs(workflows) do
	table.insert(specs, { import = workflow .. ".plugins" })
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
		log = { "-50" }, -- (L)og에서 몇개나 보여줄지
	},
	diff = {
		cmd = "diffview.nvim",
	},
	change_detection = {
		-- automatically check for config file changes and reload the ui
		enabled = false,
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
			["<localleader>t"] = {
				function(plugin)
					require("lazy.util").float_term(nil, {
						cwd = plugin.dir,
						size = {
							width = 0.95,
							height = 0.95,
						},
					})
				end,
				desc = "Open terminal in plugin dir",
			},
			["Z"] = {
				function(plugin)
					vim.cmd(":tcd " .. plugin.dir)
					vim.fn.feedkeys('0wvv"9y', "x")
					local commit = vim.fn.getreg("9")
					local first_char = commit:sub(1, 1)
					local is_alphanumeric = first_char:match("[%w]") ~= nil

					if is_alphanumeric then
						local args = ("-C=%s"):format(plugin.dir) .. " " .. commit .. "^!"
						vim.cmd("DiffviewOpen " .. args)
					else
						vim.cmd("DiffviewFileHistory --reverse --range=HEAD..origin/HEAD")
					end
				end,
				desc = "DiffviewOpen with current commit hash & CD into plugin dir",
			},
		},
	},
})

-- Function to load modules from directory and its subdirectories
local function load_directory(dir_path, module_prefix)
	if vim.fn.isdirectory(dir_path) == 1 then
		local lua_files_in_current_dir = vim.fn.glob(dir_path .. "/*.lua")
		for file in string.gmatch(lua_files_in_current_dir, "[^\n]+") do
			-- plugins.lua는 이미 lazy.nvim에서 로드했으므로 제외
			if not file:match("plugins.lua$") then
				local module_name = vim.fn.fnamemodify(file, ":t:r") -- 파일 확장자 제거
				require("utils").safe_require(module_prefix .. "." .. module_name)
			end
		end

		-- 하위 디렉토리도 재귀적으로 실행
		local subdirs = vim.fn.glob(dir_path .. "/*/")
		for subdir in string.gmatch(subdirs, "[^\n]+") do
			local subdir_name = vim.fn.fnamemodify(subdir:sub(1, -2), ":t") -- Remove trailing slash and get dir name
			local subdir_module_prefix = module_prefix .. "." .. subdir_name
			load_directory(subdir, subdir_module_prefix)
		end
	end
end

-- 워크플로우별 추가 설정(plug-in 외 다른놈들) 적용
for _, wf in ipairs(workflows) do
	local wf_dir = vim.fn.stdpath("config") .. "/lua/" .. wf:gsub("%.", "/")
	load_directory(wf_dir, wf)
end
