local map = vim.keymap.set

vim.opt.tabstop = 4 -- 탭을 2칸으로 설정
vim.opt.shiftwidth = 4 -- 자동 들여쓰기 2칸
vim.opt.softtabstop = 4 -- 백스페이스로 2칸씩 지우기
vim.opt.expandtab = true -- 탭을 공백으로 변환

map({ "n", "v" }, "<Right>", "<Esc>WviWo")
map({ "n", "v" }, "<Left>", "<Esc>BviWo")
local function deprecated_ToggleBracket()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line_num = cursor_pos[1]
    local col_num = cursor_pos[2]
    local line = vim.api.nvim_get_current_line()

    local header_pattern = "^#+%s"
    local link_pattern = "%[%s*.+%]%(.+%)"
    local unchecked_pattern = " %[%-%] $"
    local unchecked_inline = "%[%-%]"
    local checked_pattern = "%[x%]"

    -- 1. 현재 라인이 '# ', '## ', '### '... 혹은 링크 패턴으로 시작하는지 확인
    if string.match(line, header_pattern) or string.match(line, link_pattern) then
        if string.match(line, unchecked_pattern) then
            line = string.gsub(line, unchecked_pattern, "")
        else
            line = line .. " [-] "
        end
    else
        -- 2. 라인에 '[-]'가 있는지 확인
        if string.match(line, unchecked_inline) then
            line = string.gsub(line, unchecked_inline, "[x] ")
        elseif string.match(line, checked_pattern) then
            line = string.gsub(line, checked_pattern, "[-] ")
        else
            local before_cursor = string.sub(line, 1, col_num)
            local after_cursor = string.sub(line, col_num + 1)
            line = before_cursor .. "[-] " .. after_cursor

            vim.api.nvim_set_current_line(line)
            vim.api.nvim_win_set_cursor(0, { line_num, col_num + 5 })
            vim.cmd("startinsert!")
            return
        end
    end

    vim.api.nvim_set_current_line(line)
    vim.api.nvim_win_set_cursor(0, { line_num, col_num })
end

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

map("i", ",,nt", function() vim.api.nvim_put({ "> [!nt]", ">", "> " }, "c", false, true) end)

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
