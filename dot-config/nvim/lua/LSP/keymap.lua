local map = vim.keymap.set
local opt = { noremap = true, silent = true }

local snp = require("snacks").picker
-- local telescope = require("telescope.builtin")
local utils = require("utils")

map("n", "K", function()
    vim.lsp.buf.hover({

        border = utils.borders.documentation_left,
        -- title = "Hover",
        focusable = true,
        max_width = 120, -- 최대 너비 제한
        max_height = 200, -- 최대 높이 제한
    })
end, opt)

map("n", "dn", function()
    vim.diagnostic.jump({ count = 1, float = false })
    ToggleVirtualText({ force = "on" })
end, opt)
map("n", "dp", function()
    vim.diagnostic.jump({ count = -1, float = false })
    ToggleVirtualText({ force = "on" })
end, opt)
map("n", "dK", function()
    vim.diagnostic.open_float()
    ToggleVirtualText({ force = "off" })
end, opt)

-- MEMO:: `<C-l>`: show autocompletion menu to prefilter (i.e. `:warning:`)

map("n", "gD", function()
    -- vim.lsp.buf.declaration()
    local config = { auto_confirm = false }
    snp.lsp_declarations(config)
end, opt)
map("n", "gd", function()
    local config = { auto_confirm = false }
    snp.lsp_definitions(config)
end, opt)
map("n", "gy", function() snp.lsp_type_definitions() end, opt)
map("n", "gI", function() snp.lsp_implementations() end, opt)
map("n", "gR", function()
    local config = { include_declaration = false, auto_confirm = false }
    snp.lsp_references(config)
end, opt)
map("n", "gi", function()
    local config = { auto_confirm = false }
    snp.lsp_incoming_calls(config)
end, opt)
map("n", "go", function()
    local config = { auto_confirm = false }
    snp.lsp_outgoing_calls(config)
end, opt)

local wk_map = require("utils").wk_map
wk_map({
    ["<Space>l"] = {
        group = "LSP",
        order = { "c", "v" },
        ["y"] = { CopyDiagnosticsAtLine, desc = "copy diagnostics at line", mode = { "n", "v" } },
        ["a"] = { vim.lsp.buf.code_action, desc = "code action", mode = { "n", "v" } },
        ["v"] = { ToggleVirtualText, desc = "virtual text toggle", mode = { "n" } },
    },
})
wk_map({
    ["<Space>lr"] = {
        group = "expand",
        order = { "n", "s" },
        ["n"] = { vim.lsp.buf.rename, desc = "reName ", mode = "n" },
        ["s"] = { "<cmd>LspRestart ", desc = "reStart", mode = "n" },
    },
})
