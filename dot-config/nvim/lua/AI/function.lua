-- Normal mode: 전체 버퍼 내용을 주석과 함께 md 코드블록 형식으로 레지스트리에 저장
function Save_entire_buffer_to_register_for_AI_prompt()
    local content = table.concat(vim.tbl_map(function(line) return "  " .. line end, vim.fn.getline(1, "$")), "\n")
    local relative_path = vim.fn.expand("%:p"):sub(#vim.fn.getcwd() + 2)
    local filetype = vim.bo.filetype
    local result = string.format(
        [[- File Path: %s
  ```%s
%s
  ```
]],
        relative_path,
        filetype,
        content
    )

    vim.fn.setreg("+", result)
    require("utils").highlight_text_temporarily(1, vim.fn.line("$"))
    vim.notify("copied entirely for AI!", vim.log.levels.INFO)
end

-- Visual mode: 선택한 텍스트를 주석과 함께 md 코드블록 형식으로 레지스트리에 저장
function Save_visual_selection_to_register_for_AI_prompt()
    -- Visual 모드 종료 후 Normal 모드로 돌아가기
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

    vim.schedule(function()
        -- MEMO:: '<' 또는 '>' 이놈들은 기본적으로 이전 visual mode의 시작과 끝을 가져온다. 그러니 일단 nomal모드로 돌아간 뒤에 가져와야 정상 순서다.
        local start_line, _ = unpack(vim.api.nvim_buf_get_mark(0, "<"))
        local end_line, _ = unpack(vim.api.nvim_buf_get_mark(0, ">"))

        -- local content = table.concat(vim.fn.getline(start_line, end_line), "\n")
        local content = table.concat(vim.tbl_map(function(line) return "  " .. line end, vim.fn.getline(start_line, end_line)), "\n")

        local relative_path = vim.fn.expand("%:p"):sub(#vim.fn.getcwd() + 2)
        local filetype = vim.bo.filetype
        local range = start_line .. ":" .. end_line

        -- local result = string.format("```%s\n## File Path: %s, %s\n%s\n```", filetype, relative_path, range, content)
        local result = string.format(
            [[- File Path: %s, %s
  ```%s
%s
  ```
]],
            relative_path,
            range,
            filetype,
            content
        )

        -- 텍스트를 레지스트리에 저장
        vim.fn.setreg("+", result)
        -- highlight_copied_text(start_line, end_line)
        vim.notify("copied selected for AI!", vim.log.levels.INFO)
    end)
end

function Save_buf_ref_of_visual_selection_to_register_for_AI_prompt()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

    vim.schedule(function()
        local start_line, _ = unpack(vim.api.nvim_buf_get_mark(0, "<"))
        local end_line, _ = unpack(vim.api.nvim_buf_get_mark(0, ">"))

        local result = string.format("#buffer:%s-%s", start_line, end_line)

        -- 텍스트를 레지스트리에 저장
        vim.fn.setreg("+", result)
        vim.fn.setreg("S", start_line)
        vim.fn.setreg("E", end_line)
        vim.notify("copied 'Buf Ref' for AI!", vim.log.levels.INFO)
    end)
end
