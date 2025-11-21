local map = vim.keymap.set
local opt = { buffer = true, silent = true }

map({ "n", "v" }, "gq", function()
    vim.cmd("q | wincmd p")
    BlinkCursorLine(500)
end, opt)
