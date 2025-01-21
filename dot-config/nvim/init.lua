-- Global variables
vim.g.mapleader = "\\" -- Set leader key

-- specs table
local workflows = {
	"qol",
	"fuzzy_find",
	"color",
	"file_tree",
	"builtin_terminal",
	"tab_win_buf",
	"git_diff",
	"syntax",
	"LSP",
	"format_lint",
	"auto_completion",
	"AI",
	"testing",
	"UI",
	"note_taking",
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
})

-- 워크플로우별 추가 설정 적용
for _, workflow in ipairs(workflows) do
	local safe_require = require("utils").safe_require

	-- 각 워크플로우의 키맵, 자동 명령 및 기타 설정 적용
	local path = "workflows." .. workflow
	if workflow == "qol" then
		path = workflow
	end

	safe_require(path .. ".highlights")
	safe_require(path .. ".option")
	safe_require(path .. ".function")
	safe_require(path .. ".auto_cmd")
	safe_require(path .. ".filetype")
	safe_require(path .. ".ui")
	safe_require(path .. ".snip")
	safe_require(path .. ".keymap")
end
