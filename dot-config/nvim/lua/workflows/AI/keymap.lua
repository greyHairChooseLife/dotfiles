local map = vim.keymap.set
local opt = { noremap = true, silent = true }

-- >>>>>>>>>>>>>>>>> context provider
map("n", ",y", Save_entire_buffer_to_register_for_AI_prompt, opt)
map("v", ",y", Save_visual_selection_to_register_for_AI_prompt, opt)
map("v", ",r", Save_buf_ref_of_visual_selection_to_register_for_AI_prompt, opt)
-- >>>>>>>>>>>>>>>>> context provider

-- DEPRECATED:: 2025-02-04, which-key
-- -- >>>>>>>>>>>>>>>>> Avante
-- map({ "n", "v" }, "<leader>aa", "<cmd>AvanteToggle<cr>", opt)
-- map("n", "<leader>af", "<cmd>AvanteFocus<cr>", opt)
-- -- >>>>>>>>>>>>>>>>> Avante

-- >>>>>>>>>>>>>>>>> Copilot
-- DEPRECATED:: 2025-03-10
-- map("i", "<A-Down>", "<Plug>(copilot-accept-line)", opt)
-- map("i", "<C-e>", "<Plug>(copilot-dismiss)", opt)
-- map("i", "<C-y>", 'copilot#Accept("\\<CR>")', {
-- 	expr = true,
-- 	replace_keycodes = false,
-- })
-- map("i", "<A-j>", "<Plug>(copilot-accept-line)", opt)
-- map("i", "<A-k>", "<Plug>(copilot-suggest)", opt)
-- map("i", "<A-l>", "<Plug>(copilot-accept-word)", opt)
-- map("i", "<A-p>", "<Plug>(copilot-previous)", opt)
-- map("i", "<A-n>", "<Plug>(copilot-next)", opt)
map("i", "<A-l>", function()
	require("copilot.suggestion").accept_word() -- virtual text가 자꾸 사라져서 짜증난다
	require("copilot.suggestion").next()
end, opt)
-- <<<<<<<<<<<<<<<<< Copilot
