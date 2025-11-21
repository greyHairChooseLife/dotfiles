local map = vim.keymap.set

map("n", "gW", function()
    vim.cmd("silent w")
    vim.notify("Saved current buffers", 2, { render = "minimal" })
end)
map("n", "gw", function()
    vim.cmd("wa")
    vim.notify("Saved all buffers", 2, { render = "minimal" })
end)

map("n", "<leader><leader>w", "<cmd>VimwikiIndex<CR>")
map("n", "<leader><leader>d", "<cmd>VimwikiDiaryIndex<CR>")

map("i", ",,T", "<ESC>:VimwikiTable ")

map("n", "<C-k>", "<cmd>VimwikiPrevLink<CR>")
map("n", "<C-j>", "<cmd>VimwikiNextLink<CR>")

map("n", "<tab>", "<cmd>VimwikiVSplitLink 1 0<CR>")
map("n", "<S-tab>", "<cmd>VimwikiVSplitLink 1 1<CR>")

local function insert_header()
    local filename = vim.fn.expand("%:t")
    filename = filename:gsub("_", " "):gsub("%.md$", "")
    local msg = "# 󰏢 " .. filename
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { msg })
end

map("i", ",,H", insert_header)
map("n", "<CR>", function()
    vim.cmd("VimwikiFollowLink")

    -- MEMO::  잠시 사용 중지
    -- local filepath = vim.fn.expand("%:p")
    -- if vim.fn.filereadable(filepath) == 0 and vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
    --   insert_header()

    --   local template_path = vim.fn.expand("%:p:h") .. "/template.md"
    --   local lines = vim.fn.readfile(template_path)
    --   -- local lines = 'hello world!'

    --   -- 템플릿 파일 내용을 현재 버퍼에 삽입
    --   vim.api.nvim_buf_set_lines(0, 2, 2, false, lines)

    --   vim.cmd("normal! zR")
    -- end
end)

map("n", "<Backspace>", "<cmd>VimwikiGoBackLink<CR>")

map("v", "<CR>", "<Plug>VimwikiNormalizeLinkVisual", { noremap = false, silent = true })

map("n", "<leader>wd", "<cmd>VimwikiDeleteFile<CR>")
map("n", "<leader>wr", "<cmd>VimwikiRenameFile<CR>")

map("n", "<C-p>", "<Plug>VimwikiGoToPrevHeader", { noremap = true, silent = true })
map("n", "<C-n>", "<Plug>VimwikiGoToNextHeader", { noremap = true, silent = true })
map("n", "<C-[>", "<Plug>VimwikiGoToPrevSiblingHeader", { noremap = true, silent = true })
map("n", "<C-]>", "<Plug>VimwikiGoToNextSiblingHeader", { noremap = true, silent = true })

-- vim.keymap.set('n', '<C-p>', '<Plug>VimwikiGoToPrevHeader', { noremap = true, silent = true })
-- vim.keymap.set('n', '<C-n>', '<Plug>VimwikiGoToNextHeader', { noremap = true, silent = true })
--
-- -- START_debug:: 저장 관련 버그가 발생한다.
-- -- vim.keymap.set('n', '<C-Up>', '<Plug>VimwikiGoToPrevSiblingHeader', { noremap = true, silent = true })
-- -- vim.keymap.set('n', '<C-Down>', '<Plug>VimwikiGoToNextSiblingHeader', { noremap = true, silent = true })
-- -- END___debug:

-- delete keymap
vim.keymap.del("n", "<Esc>") -- 노멀모드에서 esc 누르면 sibling heading을 찾는다.

map({ "n", "v" }, "<Right>", "<Esc>WviWo")
map({ "n", "v" }, "<Left>", "<Esc>BviWo")
