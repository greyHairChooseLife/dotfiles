-- Markdown custom folding
-- BufWinEnter autocmd 사용 이유:
--   ftplugin 실행 시점에는 BufReadPost autocmd 체인이 아직 진행 중이다.
--   vim.schedule만으로는 nvim-tree 등 플러그인이 창에 버퍼를 표시하면서
--   foldexpr를 전역값으로 재설정하는 경우를 막지 못한다.
--   BufWinEnter는 버퍼가 실제로 창에 표시된 직후 발생하므로
--   어떤 경로(직접 열기, nvim-tree, picker 등)로 열어도 마지막에 실행된다.
local ok, err = pcall(require, "note_taking.markdown_fold")
if not ok then vim.notify("markdown_fold load error: " .. tostring(err), vim.log.levels.ERROR) end

local bufnr = vim.api.nvim_get_current_buf()
vim.api.nvim_create_autocmd("BufWinEnter", {
    buffer = bufnr,
    once = true,
    callback = function()
        vim.cmd([[
        setlocal foldmethod=expr
        setlocal foldexpr=v:lua.MarkdownFoldExpr()
        setlocal foldtext=v:lua.MarkdownFoldText()
        setlocal foldlevel=99
        setlocal foldcolumn=1
    ]])
    end,
})

local map = vim.keymap.set

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.textwidth = 95
-- BUG:: not working as expected
-- n: 리스트 인식, j: 주석 리더 제거, c: 긴 줄 자동 래핑
vim.opt.formatoptions:append("n")
-- 리스트 패턴 설정 (불렛 포인트 및 숫자 리스트 대응)
vim.opt.formatlistpat = [[^\s*[-*+]\s\+]]
-- 특정 플러그인이 설정한 formatexpr이 있다면 초기화 (gq가 내장 기능을 쓰도록 함)
vim.opt.formatexpr = ""

map({ "n", "v" }, "<Right>", "<Esc>WviWo")
map({ "n", "v" }, "<Left>", "<Esc>BviWo")

local function ToggleBracket()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line_num = cursor_pos[1]
    local col_num = cursor_pos[2]
    local line = vim.api.nvim_get_current_line()

    local unchecked_pattern = "%[% %]"
    local checked_pattern = "%[x%]"
    local canceled_pattern = "%[c%]"
    local td_pattern = "%[!td%]"
    local tdd_pattern = "%[!tdd%]"
    local tdc_pattern = "%[!tdc%]"

    -- 2. 라인에 '[-]'가 있는지 확인
    if string.match(line, unchecked_pattern) then
        line = string.gsub(line, unchecked_pattern, "[x]")
    elseif string.match(line, checked_pattern) then
        line = string.gsub(line, checked_pattern, "[c]")
    elseif string.match(line, canceled_pattern) then
        line = string.gsub(line, canceled_pattern, "[ ]")
    elseif string.match(line, td_pattern) then
        line = string.gsub(line, td_pattern, "[!tdd]")
    elseif string.match(line, tdd_pattern) then
        line = string.gsub(line, tdd_pattern, "[!tdc]")
    elseif string.match(line, tdc_pattern) then
        line = string.gsub(line, tdc_pattern, "[!td]")
    end

    vim.api.nvim_set_current_line(line)
    vim.api.nvim_win_set_cursor(0, { line_num, col_num })
end

map("n", "<Space><Space>", ToggleBracket)

-- callouts
map("i", ",,qt", function()
    vim.api.nvim_put({ "> [!qt] ", ">   󱞪 " }, "c", false, true)

    -- 커서를 [!qt]의 q 뒤로 이동
    local row = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_win_set_cursor(0, { row - 1, 10 })
end)

map("i", ",,td", function()
    local date = vim.fn.system('date "+%Y-%m-%d"')
    date = date:gsub("\n$", "")
    vim.api.nvim_put({ "> [!td]", ">", "> - [ ] aaa", "> - [ ] bbb" }, "c", false, true)

    -- 커서를 [!qt]의 q 뒤로 이동
    -- local row = unpack(vim.api.nvim_win_get_cursor(0))
    -- vim.api.nvim_win_set_cursor(0, { row - 1, 10 })
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end)

map("i", ",,rf", function() vim.api.nvim_put({ "> [!rf]", "> ", "> " }, "c", false, true) end)

map("i", ",,nt", function() vim.api.nvim_put({ "> [!NOTE]", ">", "> " }, "c", false, true) end)

map("i", ",,lg", function()
    local date = vim.fn.system('date "+%Y-%m-%d"')
    date = date:gsub("\n$", "")
    -- vim.api.nvim_put({ "> [!lg] Log " .. date, "> - " }, 'c', false, true)
    vim.api.nvim_put({ "> [!lg] Log " .. date, "> " }, "c", false, true)

    -- 커서를 [!qt]의 q 뒤로 이동
    -- local row = unpack(vim.api.nvim_win_get_cursor(0))
    -- vim.api.nvim_win_set_cursor(0, { row - 1, 10 })
end)

map("i", ",,cn", function() vim.api.nvim_put({ "> [!cn] 개념정리", "> ", "> " }, "c", false, true) end)

map("i", ",,co", function() vim.api.nvim_put({ "> [!" }, "c", false, true) end)

map("v", "<C-b>", ":lua require('markdowny').bold()<cr>", { buffer = true })
map("v", "<C-i>", ":lua require('markdowny').italic()<cr>", { buffer = true })
map("v", "<C-c>", ":lua require('markdowny').cancel()<cr>", { buffer = true })
map("v", "<C-k>", ":lua require('markdowny').link()<cr>", { buffer = true })
map("v", "<C-e>", ":lua require('markdowny').code()<cr>", { buffer = true })

map("n", "<CR>", "<cmd>RenderMarkdown buf_toggle<CR>")

-- 다음/이전 마크다운 링크로 이동 ([text](url) 또는 [[wikilink]] 패턴)
map("n", "<C-n>", function() vim.fn.search("]\\s*(\\|\\[\\[", "sW") end, { buffer = true })
map("n", "<C-p>", function() vim.fn.search("]\\s*(\\|\\[\\[", "sbW") end, { buffer = true })
