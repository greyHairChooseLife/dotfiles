local map = vim.keymap.set
local opt = { buffer = true, silent = true }

map("n", "dd", QF_RemoveItem, opt)
map("n", "DD", QF_ClearList, opt)
map({ "n", "v" }, "<C-n>", QF_MoveNext, opt)
map({ "n", "v" }, "<C-p>", QF_MovePrev, opt)
map({ "n", "v" }, "gq", function()
    vim.cmd("q | wincmd p")
    BlinkCursorLine(500)
end, opt)
