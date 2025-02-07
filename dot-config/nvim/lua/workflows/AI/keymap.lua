local map = vim.keymap.set
local opt = { noremap = true, silent = true }

-- >>>>>>>>>>>>>>>>> context provider
map("n", ",y", Save_entire_buffer_to_register_for_AI_prompt, opt)
map("v", ",y", Save_visual_selection_to_register_for_AI_prompt, opt)
-- >>>>>>>>>>>>>>>>> context provider

-- DEPRECATED:: 2025-02-04, which-key
-- -- >>>>>>>>>>>>>>>>> Avante
-- map({ "n", "v" }, "<leader>aa", "<cmd>AvanteToggle<cr>", opt)
-- map("n", "<leader>af", "<cmd>AvanteFocus<cr>", opt)
-- -- >>>>>>>>>>>>>>>>> Avante

-- >>>>>>>>>>>>>>>>> Copilot
map("i", "<A-Down>", "<Plug>(copilot-accept-line)", opt)
map("i", "<C-e>", "<Plug>(copilot-dismiss)", opt)
-- <<<<<<<<<<<<<<<<< Copilot
