local utils = require("utils")
local diag_signs = utils.icons.diagnostics

-- Diagnostic settings
vim.diagnostic.config({
    virtual_text = false,
    -- virtual_text = {
    -- 	prefix = " ",
    -- },
    virtual_lines = false,
    underline = false,
    update_in_insert = true, -- 입력 모드 중 업데이트 비활성화
    severity_sort = true, -- 심각도에 따라 정렬
    float = {
        -- border = "single",
        -- TODO:: 레딧에 물어봄
        -- https://www.reddit.com/r/neovim/comments/1jqhq3p/custom_diagnostic_border_using_table_type_throws/
        border = utils.borders.diagnostics,
        max_width = 120, -- 최대 너비 제한
    },
    signs = {
        priority = 1,
        text = {
            [vim.diagnostic.severity.ERROR] = diag_signs.Error,
            [vim.diagnostic.severity.WARN] = diag_signs.Warn,
            [vim.diagnostic.severity.HINT] = diag_signs.Hint,
            [vim.diagnostic.severity.INFO] = diag_signs.Info,
        },
    },
})

-- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "none" }) -- blink.cmp에서 정의
