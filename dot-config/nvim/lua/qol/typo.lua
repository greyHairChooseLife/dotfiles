vim.cmd([[cab sdbg lua Snacks.debug.inspect(<c-e>]])
vim.cmd([[iab sdbg Snacks.debug.inspect(]])

-- common typo
vim.cmd([[iab teh the]])
vim.cmd([[iab depreacted deprecated]])
vim.cmd([[iab Depreacted Deprecated]])
-- vim.cmd([[iab rnage%* range%*]]) glob, 와일드카드 안되는듯?
vim.cmd([[iab reutrn return]])

vim.cmd([[iab null NULL]])
vim.cmd([[iab prinft printf]])
