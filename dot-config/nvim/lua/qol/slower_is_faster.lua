vim.keymap.set("n", "h", function()
    if vim.v.count == 0 then
        return ","
    else
        return "h"
    end
end, { expr = true })

vim.keymap.set("n", "l", function()
    if vim.v.count == 0 then
        return ";"
    else
        return "l"
    end
end, { expr = true })
