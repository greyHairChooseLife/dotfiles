local opt = vim.opt
local g = vim.g
local diag = vim.diagnostic

opt.background = "dark"

-- 'true color' for tmux with alacritty
-- ref: https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
opt.termguicolors = true
-- vim.cmd'colorscheme yourfavcolorscheme'

-- General editor settings
opt.mouse = ""
opt.clipboard = "unnamedplus"
opt.undofile = true -- Maintain undo history between sessions
opt.swapfile = false

-- UI settings
opt.number = true
opt.relativenumber = true
opt.fillchars = "vert:┃"
opt.splitright = true -- Open vertical splits to the right

-- Indentation settings
opt.expandtab = true
opt.autoindent = true
opt.tabstop = 2
opt.shiftwidth = 2

-- Folding settings
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevel = 99
opt.foldmethod = "indent"
opt.foldenable = false
opt.formatoptions:remove("f") -- Prevent auto-folding during formatting

-- Session settings
opt.sessionoptions = "globals,blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"


-- Diagnostic settings
diag.config({
	virtual_text = true, -- 진단 메시지를 줄 안에 표시
	underline = true,
	signs = false, -- sign column에 아이콘 표시
	update_in_insert = false, -- 입력 모드 중 업데이트 비활성화
	severity_sort = true, -- 심각도에 따라 정렬
})

local diag_signs = require("core.utils").icons.diagnostics
for type, icon in pairs(diag_signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl })
end

vim.opt.completeopt = { "menu", "menuone", "noselect" }
