local map = vim.keymap.set

map("v", "<C-b>", ":lua require('markdowny').bold()<cr>", { buffer = true })
map("v", "<C-i>", ":lua require('markdowny').italic()<cr>", { buffer = true })
map("v", "<C-c>", ":lua require('markdowny').cancel()<cr>", { buffer = true })
map("v", "<C-k>", ":lua require('markdowny').link()<cr>", { buffer = true })
map("v", "<C-e>", ":lua require('markdowny').code()<cr>", { buffer = true })
