vim.cmd([[cab dbg lua Snacks.debug.inspect(<c-e>]])
vim.cmd([[iab dbg Snacks.debug.inspect(]])

-- common typo
vim.cmd([[iab teh the]])
vim.cmd([[iab depreacted deprecated]])
vim.cmd([[iab Depreacted Deprecated]])
-- vim.cmd([[iab rnage%* range%*]]) glob, 와일드카드 안되는듯?
vim.cmd([[iab reutrn return]])
