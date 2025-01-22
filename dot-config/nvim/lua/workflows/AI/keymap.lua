local map = vim.keymap.set
local opt = { noremap = true, silent = true }

-- >>>>>>>>>>>>>>>>> context provider
map("n", "<leader>y", Save_entire_buffer_to_register_for_AI_prompt, opt)
map("v", "<leader>y", Save_visual_selection_to_register_for_AI_prompt, opt)
-- >>>>>>>>>>>>>>>>> context provider

-- >>>>>>>>>>>>>>>>> Avante
map("n", "<leader>aa", "<cmd>AvanteChat<cr>", opt)
map("n", "<leader>af", "<cmd>AvanteFocus<cr>", opt)
-- >>>>>>>>>>>>>>>>> Avante

-- >>>>>>>>>>>>>>>>> Copilot
map("i", "<A-Down>", "<Plug>(copilot-accept-line)", opt)
map("i", "<C-e>", "<Plug>(copilot-dismiss)", opt)
-- <<<<<<<<<<<<<<<<< Copilot
