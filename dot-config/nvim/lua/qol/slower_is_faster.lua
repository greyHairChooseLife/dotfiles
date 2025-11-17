local map = vim.keymap.set
local opt = { noremap = true, silent = true }

vim.keymap.set({ "n", "v" }, "h", function()
    if vim.v.count == 0 then
        return ","
    else
        return "h"
    end
end, { expr = true })

vim.keymap.set({ "n", "v" }, "l", function()
    if vim.v.count == 0 then
        return ";"
    else
        return "l"
    end
end, { expr = true })

vim.keymap.set({ "n", "v" }, "j", function()
    if vim.v.count == 0 then
        return "`"
    else
        return "j"
    end
end, { expr = true })

vim.keymap.set({ "n", "v" }, "k", function()
    if vim.v.count == 0 then
        vim.cmd("NoiceDismiss")
        BlinkCursorLine()
    else
        return "k"
    end
end, { expr = true })
