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

vim.keymap.set("n", "j", function()
    if vim.v.count == 0 then
        -- move mark up & down
        -- vim.notify("normal! " .. vim.v.count .. "j")
        -- vim.cmd("normal! " .. vim.v.count .. "j")
        -- return "j"
    else
        return "j"
    end
end, { expr = true })

vim.keymap.set("n", "k", function()
    if vim.v.count ~= 0 then return "k" end
end, { expr = true })
