local map = vim.keymap.set

vim.api.nvim_create_autocmd("FileType", {
    pattern = "vimwiki",
    callback = function()
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
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown" },
    callback = function()
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
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "codecompanion" },
    callback = function()
        -- KEYMAPS
        map("v", "<C-b>", ":lua require('markdowny').bold()<cr>", { buffer = true })
        map("v", "<C-i>", ":lua require('markdowny').italic()<cr>", { buffer = true })
        map("v", "<C-c>", ":lua require('markdowny').cancel()<cr>", { buffer = true })
        map("v", "<C-k>", ":lua require('markdowny').link()<cr>", { buffer = true })
        map("v", "<C-e>", ":lua require('markdowny').code()<cr>", { buffer = true })
    end,
})
