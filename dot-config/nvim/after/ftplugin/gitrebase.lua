vim.cmd("WinShift far_up")

-- KEYMAP
local map = vim.keymap.set
local opt = { buffer = true, silent = true }

map("n", "gq", function()
    vim.cmd("q!")
    vim.notify("Rebase Aborted!", 4, { render = "minimal" })
end, opt)
