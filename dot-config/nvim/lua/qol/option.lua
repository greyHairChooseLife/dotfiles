local opt = vim.opt

opt.background = "dark"
opt.cursorline = true

-- 'true color' for tmux with alacritty
-- ref: https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
opt.termguicolors = true
-- vim.cmd'colorscheme yourfavcolorscheme'

-- General editor settings
opt.modeline = false
opt.mouse = ""
opt.clipboard = "unnamedplus"
opt.undofile = false -- Maintain undo history between sessions
opt.swapfile = false

-- UI settings
opt.number = false -- just leap & status-line
opt.relativenumber = false -- just leap & status-line
opt.signcolumn = "yes:2"
opt.foldcolumn = "0"
opt.foldmethod = "expr" -- indent
-- 버퍼에 tree-sitter 파서가 없으면 foldexpr가 폴드를 만들지 못한다.
-- 이때는 indent 폴딩으로 대체한다.
function _G.FoldExpr()
    if vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] then return vim.treesitter.foldexpr() end
    return vim.fn.indent(vim.v.lnum) / vim.fn.shiftwidth()
end
opt.foldexpr = "v:lua.FoldExpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldnestmax = 4
require("UI.foldtext")
--
-- -- workaround: neovim#32759 vim.treesitter.foldexpr()가 폴드 시작줄을
-- -- 편집하면 그 폴드를 임의로 닫는 버그. 편집 직후 커서가 있는 폴드가
-- -- 닫혀 있으면 zv로 다시 연다.
-- local fold_workaround = vim.api.nvim_create_augroup("FoldEditWorkaround", { clear = true })
-- local function reopen_fold_at_cursor()
--     if vim.fn.foldclosed(vim.fn.line(".")) ~= -1 then vim.cmd("normal! zv") end
-- end
-- vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
--     group = fold_workaround,
--     callback = function() vim.schedule(reopen_fold_at_cursor) end,
-- })
opt.fillchars = {
    vert = "┃", -- 수직 창 구분선
    fold = " ", -- 접힌 텍스트 표시
    -- foldcolumn이 > 0인 filetype (markdown, vimwiki, aerial 등)에서만 표시됨
    foldopen = "▾",
    foldsep = "│",
    foldclose = "▸",
    -- diff = "", -- diff 모드 삭제된 라인
    eob = " ", -- 버퍼 끝의 빈 라인 (~) 대체
    horiz = "━", -- 수평 창 구분선
    horizup = "┻", -- 수평-수직 교차점
    horizdown = "┳", -- 수평-수직 교차점
    vertleft = "┫", -- 수직-수평 교차점
    vertright = "┣", -- 수직-수평 교차점
    stl = "─",
    stlnc = "-",
}
opt.splitright = true -- Open vertical splits to the right
opt.splitbelow = true

-- Indentation settings
opt.expandtab = true
opt.autoindent = true
opt.tabstop = 2
opt.shiftwidth = 2

-- Session settings
opt.sessionoptions = "globals,blank,buffers,curdir,help,tabpages,winsize,winpos,terminal"

-- opt.completeopt = { "menu", "menuone", "noselect" }
opt.completeopt = { "menu", "menuone", "popup" }

opt.diffopt = "internal,filler,closeoff,indent-heuristic,linematch:60,algorithm:histogram"

vim.filetype.add({
    pattern = {
        ["%.env%..*"] = "sh",
    },
})
