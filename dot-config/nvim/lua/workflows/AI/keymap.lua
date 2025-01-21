local map = vim.keymap.set
local opt = { noremap = true, silent = true }

map("n", "<leader>y", Save_entire_buffer_to_register_for_AI_prompt, opt)
map("v", "<leader>y", Save_visual_selection_to_register_for_AI_prompt, opt)

map("i", "<A-Down>", "<Plug>(copilot-accept-line)")
