local opt = vim.opt

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
opt.number = false -- just leap & status-line
opt.relativenumber = false -- just leap & status-line
opt.signcolumn = "yes:2"
-- opt.foldcolumn = "2"
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

-- opt.completeopt = { "menu", "menuone", "noselect" }
opt.completeopt = { "menu", "menuone", "popup" }

opt.diffopt = "internal,filler,closeoff,indent-heuristic,linematch:60,algorithm:histogram"
