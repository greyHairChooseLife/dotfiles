local map = vim.keymap.set
local opt = { noremap = true, silent = true }

-- Define disallowed filetypes and buftypes (customize as needed)
local disallowed_filetypes = { "help", "qf", "markdown", "vimwiki" } -- example: disable in help and quickfix
local disallowed_buftypes = { "nofile", "terminal" } -- example: disable in nofile and terminal buffers

local function is_disabled()
    local ft = vim.bo.filetype
    local bt = vim.bo.buftype
    return vim.tbl_contains(disallowed_filetypes, ft) or vim.tbl_contains(disallowed_buftypes, bt)
end

map({ "n", "v" }, "h", function()
    if is_disabled() then return "h" end
    return vim.v.count == 0 and "," or "h"
end, { expr = true })

map({ "n", "v" }, "l", function()
    if is_disabled() then return "l" end
    return vim.v.count == 0 and ";" or "l"
end, { expr = true })

map({ "n", "v" }, "j", function()
    if is_disabled() then return "j" end
    return vim.v.count == 0 and "`" or "j"
end, { expr = true })

map({ "n", "v" }, "k", function()
    if is_disabled() then return "k" end
    if vim.v.count == 0 then
        vim.cmd("NoiceDismiss")
        BlinkCursorLine()
    else
        return "k"
    end
end, { expr = true })
